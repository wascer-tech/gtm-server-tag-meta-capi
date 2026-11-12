'use strict';
// System Log: a copia do request/resposta da Graph API para o coletor do pod.
// Reaproveita o shim de test/sandbox.js (o mesmo de test/run.js); o gancho
// `env.live` entrega url, options e a string crua do corpo de cada chamada HTTP.
// Rodar: node --test
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { runTemplate } = require('./sandbox');

const endpoint = 'https://system-log.wascer.internal/log';
const traceId = '12345678-1234-4234-8234-123456789abc';
const ENVELOPE_KEYS = ['trace_id', 'platform', 'tag_name', 'event_name', 'event_type',
  'request_method', 'request_url', 'request_body', 'response_status', 'response_body', 'duration_ms'];

const TEMPLATE = fs.readFileSync(path.join(__dirname, '..', 'template.tpl'), 'utf8');
function section(name) {
  return TEMPLATE.split('___' + name + '___')[1].split(/^___[A-Z_]+___$/m)[0];
}
const CODE = section('SANDBOXED_JS_FOR_SERVER');
const PARAMETERS = JSON.parse(section('TEMPLATE_PARAMETERS'));
const PERMISSIONS = JSON.parse(section('SERVER_PERMISSIONS'));
// fixture = secao SANDBOXED_JS_FOR_SERVER de `git show origin/main:template.tpl` antes desta mudanca
const MAIN_CODE = fs.readFileSync(path.join(__dirname, 'fixtures', 'sandboxed-js.main.txt'), 'utf8');
const purchase = () => JSON.parse(
  fs.readFileSync(path.join(__dirname, 'fixtures', 'purchase-ga4.json'), 'utf8'));

function permission(name) {
  const entry = PERMISSIONS.find((p) => p.instance.key.publicId === name);
  assert.ok(entry, 'template sem a permissao ' + name);
  return Object.fromEntries(entry.instance.param.map((p) => [p.key, p.value]));
}
const allowedUrls = () => permission('send_http').urls.listItem.map((i) => i.string);
const allowedHeaders = () =>
  permission('read_request').headerWhitelist.listItem.map((i) => i.mapValue[0].string);

const baseData = {
  datasetId: '111122223333444', accessToken: 'TOKEN_DE_TESTE', actionSource: 'website',
  eventType: 'standard', standardEventName: 'Purchase', enableEventEnhancement: false,
  autoMapUserData: true, autoMapCustomData: true, acceptFbPrefixes: true, readFbCookies: true,
  buildFbcFromUrl: true, setFbCookies: true, generateFbp: false, cookieDomainSource: 'auto',
  adStorageConsent: 'not_required', logType: 'no'
};

// Dispara a tag. Devolve o estado observavel na hora (calls, logs) e `done`,
// que resolve com o resultado depois que tudo assentou.
function start(options = {}) {
  const calls = [], logs = [], deferred = [];
  let now = 1756231200000;
  const headers = Object.assign({ 'user-agent': 'Mozilla/5.0 Teste', 'x-wascer-log': '1',
    'x-wascer-trace-id': traceId }, options.headers);
  const env = {
    eventData: options.event || purchase(),
    cookies: {},
    // Como no GTM: header fora da whitelist do read_request nao e lido.
    headers: new Proxy(headers, { get(target, key) {
      assert.ok(allowedHeaders().includes(key), 'read_request negou ' + String(key));
      return target[key];
    } }),
    clock: () => now,
    live(url, httpOptions, body) {
      assert.ok(allowedUrls().some((allowed) => url.indexOf(allowed) === 0), 'send_http negou ' + url);
      calls.push({ url, options: JSON.parse(JSON.stringify(httpOptions)), body });
      if (url === endpoint) {
        logs.push(JSON.parse(body));
        if (options.collectorMode === 'throw') throw new Error('collector synchronous error');
        if (options.collectorMode === 'reject') return Promise.reject({ reason: 'failed' });
        return Promise.resolve({ statusCode: 202, headers: {}, body: '' });
      }
      const index = calls.filter((c) => c.url !== endpoint).length - 1;
      return new Promise((resolve, reject) => {
        const complete = () => {
          now += 37;
          const error = options.vendorError;
          if (error) return reject(error);
          const status = [].concat(options.status === undefined ? 200 : options.status);
          resolve({
            statusCode: status[index % status.length],
            headers: { authorization: 'response-credential-never-copy' },
            body: options.responseBody === undefined ? '{"events_received":1}\n' : options.responseBody
          });
        };
        if (options.vendorPending) deferred.push(complete); else complete();
      });
    }
  };
  const code = options.code === undefined ? CODE : options.code;
  const done = runTemplate(code, Object.assign({}, baseData, options.data), env).then((r) => {
    assert.equal(r.error, undefined, 'a tag nao pode lancar: ' + (r.error && r.error.stack));
    return r;
  });
  return { calls, logs, done, completeVendor: () => deferred.splice(0).forEach((f) => f()) };
}

async function run(options) {
  const s = start(options);
  const r = await s.done;
  return { calls: s.calls, logs: s.logs, vendorCalls: s.calls.filter((c) => c.url !== endpoint),
    success: r.success, failure: r.failure, failureReason: r.failureReason,
    cookies: r.captured.cookies };
}

const outcome = (r) => ({ success: r.success, failure: r.failure, failureReason: r.failureReason,
  vendorCalls: r.vendorCalls, cookies: r.cookies });

test('sem x-wascer-log: so a chamada a Graph API, nenhuma ao coletor', async () => {
  const r = await run({ headers: { 'x-wascer-log': undefined } });
  assert.equal(r.calls.length, 1);
  assert.notEqual(r.calls[0].url, endpoint);
  assert.equal(r.logs.length, 0);
  assert.equal(r.success, true);
  assert.equal(r.failure, false);
});

for (const flag of ['0', 'true', '1 ', '01', '', 1, true]) {
  test('x-wascer-log = ' + JSON.stringify(flag) + ': nenhuma chamada ao coletor', async () => {
    const r = await run({ headers: { 'x-wascer-log': flag } });
    assert.equal(r.calls.length, 1);
    assert.equal(r.logs.length, 0);
    assert.equal(r.success, true);
  });
}

test('x-wascer-log = "1" e Meta 200: uma copia com o envelope exato', async () => {
  const s = start({ vendorPending: true });
  assert.equal(s.calls.length, 1, 'so a Graph API antes da resposta');
  assert.equal(s.logs.length, 0, 'nada e copiado antes de a Meta responder');
  s.completeVendor();
  const r = await s.done;
  assert.equal(s.calls.length, 2);
  assert.equal(s.logs.length, 1);
  const [vendor, collector] = s.calls;
  const row = s.logs[0];
  assert.equal(collector.url, endpoint);
  assert.equal(collector.options.method, 'POST');
  assert.deepEqual(Object.keys(row).sort(), ENVELOPE_KEYS.slice().sort());
  assert.equal(row.trace_id, traceId);
  assert.equal(row.platform, 'meta');
  assert.equal(row.tag_name, 'Meta CAPI');
  assert.equal(row.event_name, 'purchase');
  assert.equal(row.event_type, 'purchase');
  assert.equal(row.request_method, 'POST');
  assert.equal(row.request_url, vendor.url);
  assert.equal(row.request_url,
    'https://graph.facebook.com/v26.0/111122223333444/events?access_token=TOKEN_DE_TESTE',
    'URL exata, sem mascara no access_token');
  assert.equal(typeof vendor.body, 'string');
  assert.equal(row.request_body, vendor.body, 'string identica, byte a byte');
  assert.equal(JSON.parse(row.request_body).data[0].event_name, 'Purchase');
  assert.equal(row.response_status, 200);
  assert.equal(row.response_body, '{"events_received":1}\n');
  assert.equal(row.duration_ms, 37);
  assert.ok(!JSON.stringify(row).includes('response-credential-never-copy'), 'headers da resposta nao vao');
  assert.equal(r.success, true);
  assert.equal(r.failure, false);
});

for (const status of [400, 503]) {
  test('Meta ' + status + ': copia com o status e o body, e a tag chama gtmOnFailure', async () => {
    const body = '{"error":{"message":"Invalid parameter"}}';
    const r = await run({ status, responseBody: body });
    assert.equal(r.logs.length, 1);
    assert.equal(r.logs[0].response_status, status);
    assert.equal(r.logs[0].response_body, body);
    assert.equal(r.logs[0].request_body, r.calls[0].body);
    assert.equal(r.failure, true);
    assert.equal(r.success, false);
  });
}

test('erro de rede na Graph API: copia com status 0 e a tag chama gtmOnFailure', async () => {
  const error = { reason: 'timed_out' };
  const r = await run({ vendorError: error });
  assert.equal(r.logs.length, 1);
  assert.equal(r.logs[0].response_status, 0);
  assert.equal(r.logs[0].response_body, 'timed_out');
  assert.equal(r.logs[0].request_url, r.calls[0].url);
  assert.equal(r.logs[0].request_body, r.calls[0].body);
  assert.equal(r.logs[0].duration_ms, 37);
  assert.equal(r.failure, true);
  assert.equal(r.success, false);
  assert.equal(r.failureReason, error, 'gtmOnFailure recebe o mesmo erro de antes');
});

test('erro de rede com error.body: response_body usa o body; sem nada: string vazia', async () => {
  const withBody = await run({ vendorError: { reason: 'failed', body: 'raw error body' } });
  assert.equal(withBody.logs[0].response_body, 'raw error body');
  const bare = await run({ vendorError: 'boom' });
  assert.equal(bare.logs[0].response_status, 0);
  assert.equal(bare.logs[0].response_body, '');
  assert.equal(bare.failure, true);
});

test('multi dataset: uma copia por entrega, cada uma com a sua URL e o seu status', async () => {
  const r = await run({ status: [200, 400], data: { enableMultiDataset: true, datasetTable: [
    { datasetId: '111', accessToken: 'A' }, { datasetId: '222', accessToken: 'B' }] } });
  assert.equal(r.vendorCalls.length, 2);
  assert.equal(r.logs.length, 2);
  const byUrl = Object.fromEntries(r.logs.map((row) => [row.request_url, row.response_status]));
  assert.deepEqual(byUrl, {
    'https://graph.facebook.com/v26.0/111/events?access_token=A': 200,
    'https://graph.facebook.com/v26.0/222/events?access_token=B': 400
  });
  assert.equal(r.success, true, 'um dataset aceitou, a tag segue reportando sucesso');
});

test('modo otimista: gtmOnSuccess sai antes, a copia so quando a resposta chega', async () => {
  // Dois datasets, um recusa: a main ja deixa uma rejeicao solta quando nenhum aceita
  // no modo otimista, e isso nao e assunto deste teste.
  const s = start({ vendorPending: true, status: [400, 200], responseBody: 'resposta',
    data: { useOptimisticScenario: true, enableMultiDataset: true, datasetTable: [
      { datasetId: '111', accessToken: 'A' }, { datasetId: '222', accessToken: 'B' }] } });
  assert.equal(s.calls.length, 2);
  assert.equal(s.logs.length, 0, 'sem resposta da Meta nao ha o que copiar');
  s.completeVendor();
  const r = await s.done;
  assert.equal(r.success, true);
  assert.equal(r.failure, false);
  assert.equal(s.logs.length, 2);
  assert.deepEqual(s.logs.map((row) => row.response_status).sort(), [200, 400],
    'status real de cada dataset, nao o sucesso otimista');
  assert.equal(s.logs[0].response_body, 'resposta');
});

test('saida cedo (sem consentimento): nenhuma entrega, nenhuma copia', async () => {
  const event = Object.assign(purchase(), { consent_state: { ad_storage: 'denied' } });
  const r = await run({ event, data: { adStorageConsent: 'required' } });
  assert.equal(r.calls.length, 0);
  assert.equal(r.success, true);
});

test('campo "Event type (System Log)": preenchido vence; vazio usa o event_name', async () => {
  const filled = await run({ data: { systemLogEventType: 'compra-site' } });
  assert.equal(filled.logs[0].event_type, 'compra-site');
  assert.equal(filled.logs[0].event_name, 'purchase');
  const empty = await run({ data: { systemLogEventType: '' } });
  assert.equal(empty.logs[0].event_type, 'purchase');
  const group = PARAMETERS[PARAMETERS.length - 1];
  assert.equal(group.name, 'logsGroup');
  const field = group.subParams[group.subParams.length - 1];
  assert.equal(field.name, 'systemLogEventType', 'ultimo campo do ultimo grupo');
  assert.equal(field.type, 'TEXT');
  assert.equal(field.displayName, 'Event type (System Log)');
  assert.equal(field.simpleValueType, true);
});

for (const [label, eventName] of [['ausente', undefined], ['nao-string', 42]]) {
  test('event_name ' + label + ': event_name e event_type vao como string vazia', async () => {
    const event = Object.assign(purchase(), { event_name: eventName });
    const r = await run({ event });
    assert.equal(r.logs[0].event_name, '');
    assert.equal(r.logs[0].event_type, '');
    assert.equal(r.success, true);
  });
}

for (const mode of ['reject', 'throw']) {
  test('coletor ' + mode + ': resultado da tag identico ao de sem copia', async () => {
    const scenarios = [{}, { status: 400 }, { vendorError: { reason: 'timed_out' } },
      { data: { useOptimisticScenario: true } }];
    for (const scenario of scenarios) {
      const off = await run(Object.assign({}, scenario, { headers: { 'x-wascer-log': undefined } }));
      const on = await run(Object.assign({}, scenario, { collectorMode: mode }));
      assert.equal(on.logs.length, 1, 'a copia foi tentada');
      assert.deepEqual(outcome(on), outcome(off));
    }
  });
}

test('x-wascer-log = "1" sem x-wascer-trace-id: trace_id vazio e a tag termina normalmente', async () => {
  const r = await run({ headers: { 'x-wascer-trace-id': undefined } });
  assert.equal(r.success, true);
  assert.equal(r.logs[0].trace_id, '');
});

test('a copia usa timeout de 500 ms e Content-Type application/json', async () => {
  const r = await run();
  assert.equal(r.calls[1].options.timeout, 500);
  assert.deepEqual(r.calls[1].options.headers, { 'Content-Type': 'application/json' });
});

test('permissoes: so o necessario entrou', () => {
  assert.deepEqual(allowedHeaders(), ['user-agent', 'referer', 'x-forwarded-for',
    'x-gtm-server-preview', 'x-wascer-log', 'x-wascer-trace-id']);
  assert.equal(permission('read_request').headerAccess.string, 'specific');
  assert.equal(permission('send_http').allowedUrls.string, 'specific');
  assert.deepEqual(allowedUrls(), ['https://graph.facebook.com/', endpoint]);
  assert.equal(permission('read_event_data').eventDataAccess.string, 'any');
});

test('com o log desligado, as chamadas a Graph API sao identicas as do template da main', async () => {
  const multi = { enableMultiDataset: true, datasetTable: [
    { datasetId: '111', accessToken: 'A' }, { datasetId: '222', accessToken: 'B' }] };
  const scenarios = [
    {},
    { data: { testEventCode: 'TEST123', apiVersionOverride: 'v27.0' } },
    { data: multi },
    { data: multi, status: [400, 200] },
    { data: multi, status: 400 },
    { data: { useOptimisticScenario: true } },
    { data: { enableEventEnhancement: true, generateFbp: true } },
    { status: 400, responseBody: '{"error":{"message":"Invalid parameter"}}' },
    { status: 503, responseBody: 'unavailable' },
    { vendorError: { reason: 'timed_out' } },
    { vendorError: 'boom' },
    { data: { adStorageConsent: 'required' },
      event: Object.assign(purchase(), { consent_state: { ad_storage: 'denied' } }) }
  ];
  for (const scenario of scenarios) {
    const off = { headers: { 'x-wascer-log': undefined } };
    const before = await run(Object.assign({}, scenario, off, { code: MAIN_CODE }));
    const after = await run(Object.assign({}, scenario, off));
    const withLog = await run(scenario);
    assert.deepEqual(after.calls, before.calls);
    assert.deepEqual(outcome(after), outcome(before));
    assert.deepEqual(outcome(withLog), outcome(before), 'ligar o log nao muda a entrega nem o resultado');
    assert.equal(withLog.logs.length, before.calls.length, 'uma copia por entrega');
  }
});

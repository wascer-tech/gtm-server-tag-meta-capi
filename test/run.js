// Roda o template.js contra payloads reais e confere o que sai.
// Uso: node test/run.js            confere tudo, sem tocar a rede
//      node test/run.js --print    mostra o payload de cada cenario
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { runTemplate } = require('./sandbox');

const ROOT = path.join(__dirname, '..');
const SOURCE = extractJs(fs.readFileSync(path.join(ROOT, 'template.tpl'), 'utf8'));
const PRINT = process.argv.includes('--print');

function extractJs(tpl) {
  const start = tpl.indexOf('___SANDBOXED_JS_FOR_SERVER___');
  const rest = tpl.slice(start + '___SANDBOXED_JS_FOR_SERVER___'.length);
  const end = rest.search(/^___[A-Z_]+___$/m);
  return rest.slice(0, end);
}

const fixture = (name) => JSON.parse(fs.readFileSync(path.join(__dirname, 'fixtures', name), 'utf8'));
const lastPart = (v) => v.split('.').slice(3).join('.');
const sha = (s) => crypto.createHash('sha256').update(s, 'utf8').digest('hex');

const baseData = {
  datasetId: '111122223333444',
  accessToken: 'TOKEN_DE_TESTE',
  actionSource: 'website',
  eventType: 'standard',
  standardEventName: 'Purchase',
  enableEventEnhancement: false,
  autoMapUserData: true,
  autoMapCustomData: true,

  acceptFbPrefixes: true,
  readFbCookies: true,
  buildFbcFromUrl: true,
  setFbCookies: true,
  generateFbp: false,
  cookieDomainSource: 'auto',
  adStorageConsent: 'not_required',
  logType: 'no'
};

let pass = 0, fail = 0;
const failures = [];

function check(label, actual, expected) {
  const a = JSON.stringify(actual), e = JSON.stringify(expected);
  if (a === e) { pass++; return; }
  fail++; failures.push({ label, expected: e, actual: a });
}
function checkTrue(label, cond) { check(label, !!cond, true); }

function run(data, env) {
  return runTemplate(SOURCE, Object.assign({}, baseData, data), env);
}

async function main() {
  // ---- 1. Purchase GA4 completo -----------------------------------------
  let r = await run({}, { eventData: fixture('purchase-ga4.json'), cookies: {},
    headers: { 'user-agent': 'Mozilla/5.0 Teste', 'x-forwarded-for': '187.1.2.3, 10.0.0.1' } });
  let ev = r.captured.requests[0].body.data[0];
  if (PRINT) print('1. purchase GA4', r.captured.requests[0]);

  check('evento padrao escolhido', ev.event_name, 'Purchase');
  check('event_id vem do transaction_id', ev.event_id, 'PED-90210');
  check('action_source', ev.action_source, 'website');
  check('event_time preservado', ev.event_time, 1756231200);

  check('email normalizado e hasheado', ev.user_data.em, sha('joao@example.com'));
  check('telefone so digitos com DDI', ev.user_data.ph, sha('5511987654321'));
  check('nome minusculo', ev.user_data.fn, sha('joão'));
  check('cidade sem espaco e sem acento fora', ev.user_data.ct, sha('sopaulo'));
  check('estado', ev.user_data.st, sha('sp'));
  check('cep sem hifen', ev.user_data.zp, sha('01310100'));
  check('pais em duas letras', ev.user_data.country, sha('br'));
  check('external_id hasheado', ev.user_data.external_id, sha('cliente-4471'));

  check('user agent cru', ev.user_data.client_user_agent, 'Mozilla/5.0 Teste');
  check('primeiro ip da cadeia, cru', ev.user_data.client_ip_address, '187.1.2.3');
  checkTrue('fbc montado a partir do fbclid', ev.user_data.fbc.indexOf('fb.2.') === 0 &&
    ev.user_data.fbc.indexOf('IwAR_teste_123') !== -1);
  check('fbp ausente quando nao ha cookie', ev.user_data.fbp, undefined);

  check('contents', ev.custom_data.contents, [
    { id: 'SKU-1', quantity: 2, item_price: 79.9 },
    { id: 'SKU-2', quantity: 1, item_price: 90.1 }]);
  check('content_ids', ev.custom_data.content_ids, ['SKU-1', 'SKU-2']);
  check('num_items soma quantidades', ev.custom_data.num_items, 3);
  check('content_type', ev.custom_data.content_type, 'product');
  check('value', ev.custom_data.value, 249.9);
  check('currency', ev.custom_data.currency, 'BRL');
  check('order_id', ev.custom_data.order_id, 'PED-90210');

  check('url do evento', ev.event_source_url,
    'https://www.lojateste.com.br/checkout/obrigado?fbclid=IwAR_teste_123');
  check('cookies escritos', r.captured.cookies.map((c) => c.name), ['_fbc']);
  check('um request', r.captured.requests.length, 1);
  checkTrue('url da graph api', r.captured.requests[0].url.indexOf(
    'https://graph.facebook.com/v26.0/111122223333444/events?access_token=') === 0);
  check('tag reportou sucesso', r.success, true);

  // ---- 2. delivery_category ligado --------------------------------------
  r = await run({ mapDeliveryCategory: true }, { eventData: fixture('purchase-ga4.json') });
  ev = r.captured.requests[0].body.data[0];
  check('delivery_category por item', ev.custom_data.contents.map((c) => c.delivery_category),
    ['home_delivery', 'in_store']);

  // ---- 3. Compatibilidade x-fb-* ----------------------------------------
  r = await run({ autoMapCustomData: false, autoMapUserData: false },
    { eventData: fixture('purchase-xfb.json') });
  ev = r.captured.requests[0].body.data[0];
  if (PRINT) print('3. compat x-fb', r.captured.requests[0]);
  check('content_ids do prefixo', ev.custom_data.content_ids, ['SKU-1', 'SKU-2']);
  check('num_items do prefixo', ev.custom_data.num_items, 3);
  check('fbp do prefixo, cru', ev.user_data.fbp, 'fb.1.1700000000000.1234567890');
  check('fbc do prefixo, cru', ev.user_data.fbc, 'fb.1.1700000000000.IwAR_legado');
  check('external_id ja hasheado passa direto',
    ev.user_data.external_id, '3d8a5f2e9c1b4a7d6e0f3c2b1a9d8e7f6c5b4a3d2e1f0a9b8c7d6e5f4a3b2c1d');
  check('genero normalizado', ev.user_data.ge, sha('m'));

  // ---- 4. Prefixo perde para a tabela de override ------------------------
  r = await run({ customDataList: [{ name: 'value', value: 999 }] },
    { eventData: fixture('purchase-ga4.json') });
  check('override vence o automap',
    r.captured.requests[0].body.data[0].custom_data.value, 999);

  // ---- 5. event_id: trim desligado por padrao ---------------------------
  const espacado = Object.assign(fixture('purchase-ga4.json'), { transaction_id: ' PED-1 ' });
  r = await run({}, { eventData: espacado });
  check('sem trim por padrao, preserva o espaco',
    r.captured.requests[0].body.data[0].event_id, ' PED-1 ');
  r = await run({ trimEventId: true }, { eventData: espacado });
  check('com trim ligado, remove', r.captured.requests[0].body.data[0].event_id, 'PED-1');

  // ---- 6. Consentimento --------------------------------------------------
  const negado = Object.assign(fixture('purchase-ga4.json'), { consent_state: { ad_storage: 'denied' } });
  r = await run({ adStorageConsent: 'required' }, { eventData: negado });
  check('consentimento negado nao envia', r.captured.requests.length, 0);
  check('mas a tag nao falha', r.success, true);
  r = await run({ adStorageConsent: 'not_required' }, { eventData: negado });
  check('default envia mesmo sem consentimento', r.captured.requests.length, 1);

  // ---- 7. Multi dataset --------------------------------------------------
  r = await run({ enableMultiDataset: true, datasetTable: [
      { datasetId: '111', accessToken: 'A' }, { datasetId: '222', accessToken: 'B' }] },
    { eventData: fixture('purchase-ga4.json') });
  check('dois requests', r.captured.requests.length, 2);
  check('datasets distintos', r.captured.requests.map((q) => q.url.split('/')[4]), ['111', '222']);

  // ---- 8. LDU e segmentacao ---------------------------------------------
  r = await run({ enableLDU: true, lduCountry: '1', lduState: '1000',
      customerSegmentation: 'new_customer_to_business' },
    { eventData: fixture('purchase-ga4.json') });
  ev = r.captured.requests[0].body.data[0];
  check('LDU', ev.data_processing_options, ['LDU']);
  check('LDU pais', ev.data_processing_options_country, 1);
  check('LDU estado', ev.data_processing_options_state, 1000);
  check('customer_segmentation', ev.customer_segmentation, 'new_customer_to_business');

  // ---- 9. test_event_code e evento nao mapeado ---------------------------
  r = await run({ testEventCode: 'TEST123' }, { eventData: { event_name: 'algo_custom' } });
  check('test_event_code no corpo', r.captured.requests[0].body.test_event_code, 'TEST123');

  // ---- 10. Indice de subdominio e fbclid ---------------------------------
  const semWww = Object.assign(fixture('purchase-ga4.json'),
    { page_location: 'https://lojateste.com.br/obrigado?fbclid=CLIQUE_A' });
  r = await run({}, { eventData: semWww });
  check('apex .com.br continua indice 2',
    r.captured.requests[0].body.data[0].user_data.fbc.split('.')[1], '2');

  const pontoCom = Object.assign(fixture('purchase-ga4.json'),
    { page_location: 'https://www.loja.com/obrigado?fbclid=CLIQUE_A' });
  r = await run({}, { eventData: pontoCom });
  check('.com da indice 1',
    r.captured.requests[0].body.data[0].user_data.fbc.split('.')[1], '1');

  // fbclid novo tem que vencer o _fbc guardado
  r = await run({}, { eventData: pontoCom,
    cookies: { _fbc: 'fb.1.1700000000000.CLIQUE_ANTIGO' } });
  check('fbclid novo reescreve o fbc antigo',
    lastPart(r.captured.requests[0].body.data[0].user_data.fbc), 'CLIQUE_A');

  // mesmo fbclid nao pode reescrever, senao o creationTime anda a cada evento
  r = await run({}, { eventData: pontoCom,
    cookies: { _fbc: 'fb.1.1700000000000.CLIQUE_A' } });
  check('mesmo fbclid preserva o cookie inteiro',
    r.captured.requests[0].body.data[0].user_data.fbc, 'fb.1.1700000000000.CLIQUE_A');

  // fbclid percent-encoded na URL
  const encoded = Object.assign(fixture('purchase-ga4.json'),
    { page_location: 'https://www.loja.com/obrigado?fbclid=IwAR%2Fabc%3Dd' });
  r = await run({}, { eventData: encoded });
  check('fbclid decodificado',
    lastPart(r.captured.requests[0].body.data[0].user_data.fbc), 'IwAR/abc=d');

  // fbc e fbp vindos do event data com underscore
  r = await run({}, { eventData: Object.assign(fixture('purchase-ga4.json'),
    { page_location: 'https://www.loja.com/obrigado', _fbp: 'fb.1.1700000000000.999' }) });
  check('_fbp do event data', r.captured.requests[0].body.data[0].user_data.fbp,
    'fb.1.1700000000000.999');

  // ---- 11. Event Type ----------------------------------------------------
  r = await run({ eventType: 'standard', standardEventName: 'Lead' },
    { eventData: fixture('purchase-ga4.json') });
  check('standard do select', r.captured.requests[0].body.data[0].event_name, 'Lead');
  r = await run({ eventType: 'custom', customEventName: 'MeuEvento' },
    { eventData: fixture('purchase-ga4.json') });
  check('custom digitado', r.captured.requests[0].body.data[0].event_name, 'MeuEvento');

  // ---- 11b. Chave de ID do item -----------------------------------------
  const skuProprio = { event_name: 'purchase', items: [
    { sku_loja: 'ABC-9', item_id: 'IGNORAR', quantity: 1, price: 10 }] };
  r = await run({ itemIdKey: 'sku_loja' }, { eventData: skuProprio });
  check('chave livre vence o item_id',
    r.captured.requests[0].body.data[0].custom_data.content_ids, ['ABC-9']);

  r = await run({ itemIdKey: '' }, { eventData: skuProprio });
  check('chave vazia cai no item_id',
    r.captured.requests[0].body.data[0].custom_data.content_ids, ['IGNORAR']);

  r = await run({}, { eventData: { event_name: 'purchase', items: [
    { id: 'SO-ID', quantity: 1 }] } });
  check('sem item_id, cai no id',
    r.captured.requests[0].body.data[0].custom_data.content_ids, ['SO-ID']);

  r = await run({ itemIdKey: 'nao_existe' }, { eventData: skuProprio });
  check('chave inexistente cai na cadeia, nao derruba o item',
    r.captured.requests[0].body.data[0].custom_data.content_ids, ['IGNORAR']);

  // ---- 12. Event Enhancement, o cookie _gtmeec ---------------------------
  const b64 = (o) => Buffer.from(JSON.stringify(o), 'utf8').toString('base64');

  // checkout grava o cookie com o que foi identificado
  r = await run({ enableEventEnhancement: true }, { eventData: fixture('purchase-ga4.json') });
  const escrito = r.captured.cookies.filter((c) => c.name === '_gtmeec')[0];
  checkTrue('checkout grava o _gtmeec', !!escrito);
  const guardado = JSON.parse(Buffer.from(escrito.value, 'base64').toString('utf8'));
  check('cookie guarda o email hasheado', guardado.em, sha('joao@example.com'));
  check('cookie nao guarda nada em texto claro',
    Object.keys(guardado).filter((k) => !/^[a-f0-9]{64}$/.test(guardado[k])), []);
  check('cookie e httpOnly e Strict',
    [escrito.options.httpOnly, escrito.options.sameSite], [true, 'Strict']);

  // page_view depois, sem nenhum dado de usuario
  const pageView = { event_name: 'page_view', page_location: 'https://www.loja.com/produto' };
  r = await run({ enableEventEnhancement: true }, { eventData: pageView });
  check('page_view sem enhancement nao teria email',
    r.captured.requests[0].body.data[0].user_data.em, undefined);

  r = await run({ enableEventEnhancement: true }, { eventData: pageView,
    cookies: { _gtmeec: b64({ em: sha('joao@example.com'), ph: sha('5511987654321') }) } });
  ev = r.captured.requests[0].body.data[0];
  check('page_view herda o email do cookie', ev.user_data.em, sha('joao@example.com'));
  check('page_view herda o telefone', ev.user_data.ph, sha('5511987654321'));

  // dado do evento vence o cookie
  r = await run({ enableEventEnhancement: true },
    { eventData: Object.assign({}, pageView, { user_data: { email_address: 'outro@example.com' } }),
      cookies: { _gtmeec: b64({ em: sha('joao@example.com') }) } });
  check('email do evento vence o do cookie',
    r.captured.requests[0].body.data[0].user_data.em, sha('outro@example.com'));

  // desligado, nao le nem escreve
  r = await run({ enableEventEnhancement: false }, { eventData: pageView,
    cookies: { _gtmeec: b64({ em: sha('joao@example.com') }) } });
  check('desligado ignora o cookie',
    r.captured.requests[0].body.data[0].user_data.em, undefined);
  check('desligado nao grava',
    r.captured.cookies.filter((c) => c.name === '_gtmeec').length, 0);

  // ---- 12b. Interoperar com o cookie da tag oficial da Meta --------------
  // Eles gravam com setCookie sem o quarto argumento, ou seja codificado, e leem
  // com getCookieValues('_gtmeec', true), ou seja cru. Os dois sentidos tem que
  // funcionar, senao o cookie compartilhado nao serve para nada.
  const payload = b64({ em: sha('joao@example.com') });

  r = await run({ enableEventEnhancement: true }, { eventData: pageView,
    cookies: { _gtmeec: encodeURIComponent(payload) } });
  check('lemos o cookie que a tag da Meta gravou codificado',
    r.captured.requests[0].body.data[0].user_data.em, sha('joao@example.com'));

  r = await run({ enableEventEnhancement: true }, { eventData: fixture('purchase-ga4.json') });
  const gravado = r.captured.cookies.filter((c) => c.name === '_gtmeec')[0];
  check('gravamos cru, que e o que a leitura sem decode deles enxerga',
    gravado.stored, gravado.value);
  checkTrue('e o valor cru e base64 valido',
    /^[A-Za-z0-9+/]+={0,2}$/.test(gravado.stored));
  check('e volta em base64 legivel',
    JSON.parse(Buffer.from(gravado.stored, 'base64').toString('utf8')).em,
    sha('joao@example.com'));

  // e o nosso proprio round-trip continua fechando
  r = await run({ enableEventEnhancement: true }, { eventData: pageView,
    cookies: { _gtmeec: gravado.stored } });
  check('round-trip com o nosso proprio cookie',
    r.captured.requests[0].body.data[0].user_data.em, sha('joao@example.com'));

  // ---- 13. Falha da Meta derruba a tag -----------------------------------
  r = await run({}, { eventData: fixture('purchase-ga4.json'),
    live: () => Promise.resolve({ statusCode: 400, headers: {}, body: '{"error":{"message":"Invalid parameter"}}' }) });
  check('resposta 400 marca falha', r.failure, true);

  report();
}

function print(title, req) {
  console.log('\n--- ' + title + ' ---');
  console.log(req.url.replace(/access_token=.*/, 'access_token=***'));
  console.log(JSON.stringify(req.body, null, 2));
}

function report() {
  console.log('');
  failures.forEach((f) => {
    console.log('  FALHOU  ' + f.label);
    console.log('     esperado: ' + f.expected);
    console.log('     recebido: ' + f.actual);
  });
  console.log((fail === 0 ? 'OK' : 'FALHAS') + '  ' + pass + ' passaram, ' + fail + ' falharam');
  process.exit(fail === 0 ? 0 : 1);
}

main().catch((e) => { console.error(e); process.exit(1); });

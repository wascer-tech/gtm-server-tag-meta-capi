___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "displayName": "Wascer Meta CAPI",
  "description": "Send server events to the Meta Conversions API from your server container.",
  "containerContexts": [
    "SERVER"
  ],
  "securityGroups": []
}

___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "configGroup",
    "displayName": "Connection",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "TEXT",
        "name": "datasetId",
        "displayName": "Dataset ID (Pixel ID)",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "valueHint": "123456789012345",
        "help": "Find it in Events Manager. Meta now calls it a Dataset ID, and the number is the same one you knew as the Pixel ID."
      },
      {
        "type": "TEXT",
        "name": "accessToken",
        "displayName": "API Access Token",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "help": "Generate it in Events Manager, under the settings of this dataset. Store it in a variable so it does not sit in plain text inside the tag."
      },
      {
        "type": "CHECKBOX",
        "name": "enableMultiDataset",
        "checkboxText": "Send this event to more than one dataset",
        "simpleValueType": true,
        "defaultValue": false,
        "help": "Use it when the same conversion has to reach two ad accounts. Each row gets its own token, and one failing row does not stop the others.",
        "subParams": [
          {
            "type": "SIMPLE_TABLE",
            "name": "datasetTable",
            "displayName": "Datasets",
            "simpleTableColumns": [
              {
                "defaultValue": "",
                "displayName": "Dataset ID",
                "name": "datasetId",
                "type": "TEXT",
                "isUnique": true
              },
              {
                "defaultValue": "",
                "displayName": "API Access Token",
                "name": "accessToken",
                "type": "TEXT"
              }
            ],
            "newRowButtonText": "Add dataset",
            "enablingConditions": [
              {
                "paramName": "enableMultiDataset",
                "paramValue": true,
                "type": "EQUALS"
              }
            ]
          }
        ]
      },
      {
        "type": "SELECT",
        "name": "actionSource",
        "displayName": "Action Source",
        "selectItems": [
          {
            "value": "website",
            "displayValue": "Website"
          },
          {
            "value": "app",
            "displayValue": "App"
          },
          {
            "value": "email",
            "displayValue": "Email"
          },
          {
            "value": "phone_call",
            "displayValue": "Phone call"
          },
          {
            "value": "chat",
            "displayValue": "Chat"
          },
          {
            "value": "physical_store",
            "displayValue": "Physical store"
          },
          {
            "value": "system_generated",
            "displayValue": "System generated"
          },
          {
            "value": "business_messaging",
            "displayValue": "Business messaging"
          },
          {
            "value": "other",
            "displayValue": "Other"
          }
        ],
        "simpleValueType": true,
        "macrosInSelect": true,
        "defaultValue": "website",
        "help": "Where the conversion happened. Website is the right answer for anything that came from a browser."
      },
      {
        "type": "TEXT",
        "name": "testEventCode",
        "displayName": "Test Event Code",
        "simpleValueType": true,
        "valueHint": "TEST12345",
        "help": "Only while you are watching Test Events in Events Manager. Leave it empty in production, because events sent with this code are not used for attribution."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "eventGroup",
    "displayName": "Event",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "RADIO",
        "name": "eventType",
        "displayName": "Event Type",
        "simpleValueType": true,
        "defaultValue": "standard",
        "radioItems": [
          {
            "value": "standard",
            "displayValue": "Standard",
            "subParams": [
              {
                "type": "SELECT",
                "name": "standardEventName",
                "macrosInSelect": true,
                "simpleValueType": true,
                "defaultValue": "Purchase",
                "selectItems": [
                  {
                    "value": "AddPaymentInfo",
                    "displayValue": "AddPaymentInfo"
                  },
                  {
                    "value": "AddToCart",
                    "displayValue": "AddToCart"
                  },
                  {
                    "value": "AddToWishlist",
                    "displayValue": "AddToWishlist"
                  },
                  {
                    "value": "CompleteRegistration",
                    "displayValue": "CompleteRegistration"
                  },
                  {
                    "value": "Contact",
                    "displayValue": "Contact"
                  },
                  {
                    "value": "CustomizeProduct",
                    "displayValue": "CustomizeProduct"
                  },
                  {
                    "value": "Donate",
                    "displayValue": "Donate"
                  },
                  {
                    "value": "FindLocation",
                    "displayValue": "FindLocation"
                  },
                  {
                    "value": "InitiateCheckout",
                    "displayValue": "InitiateCheckout"
                  },
                  {
                    "value": "Lead",
                    "displayValue": "Lead"
                  },
                  {
                    "value": "PageView",
                    "displayValue": "PageView"
                  },
                  {
                    "value": "Purchase",
                    "displayValue": "Purchase"
                  },
                  {
                    "value": "Schedule",
                    "displayValue": "Schedule"
                  },
                  {
                    "value": "Search",
                    "displayValue": "Search"
                  },
                  {
                    "value": "StartTrial",
                    "displayValue": "StartTrial"
                  },
                  {
                    "value": "SubmitApplication",
                    "displayValue": "SubmitApplication"
                  },
                  {
                    "value": "Subscribe",
                    "displayValue": "Subscribe"
                  },
                  {
                    "value": "ViewContent",
                    "displayValue": "ViewContent"
                  }
                ]
              }
            ]
          },
          {
            "value": "custom",
            "displayValue": "Custom",
            "subParams": [
              {
                "type": "TEXT",
                "name": "customEventName",
                "simpleValueType": true,
                "valueHint": "SubscribeNewsletter",
                "valueValidators": [
                  {
                    "type": "NON_EMPTY"
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "eventId",
        "displayName": "Event ID",
        "simpleValueType": true,
        "help": "The key that stops a conversion from being counted twice. It has to be the exact same string the browser pixel sends as eventID. Leave it empty and the tag reads event_id, then transaction_id, from the incoming event."
      },
      {
        "type": "CHECKBOX",
        "name": "trimEventId",
        "checkboxText": "Trim spaces around the Event ID",
        "simpleValueType": true,
        "defaultValue": false,
        "help": "Meta only deduplicates when the two strings match character for character, so a stray space breaks the pair. Turn this on only if you also trim it on the browser side. Trimming just one side is what breaks a pair that used to work."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "userDataGroup",
    "displayName": "User Data",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "LABEL",
        "name": "userDataLabel",
        "displayName": "User Data is what lets Meta match the event to an account, and it is what moves Event Match Quality. The tag hashes what needs hashing. Values that already arrive hashed are passed through untouched."
      },
      {
        "type": "CHECKBOX",
        "name": "autoMapUserData",
        "checkboxText": "Read user data from the incoming event",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Picks up email, phone, name, address and external ID from the event, plus the _fbc and _fbp cookies."
      },
      {
        "type": "TEXT",
        "name": "userDataObject",
        "displayName": "User data object",
        "simpleValueType": true,
        "help": "A variable holding an object with the user data fields. Use it when your data does not sit where the automatic mapping looks."
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "userDataList",
        "displayName": "User data",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Parameter",
            "name": "name",
            "type": "TEXT",
            "isUnique": true
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT"
          }
        ],
        "newRowButtonText": "Add parameter",
        "help": "Parameter names as Meta writes them: em, ph, fn, ln, db, ge, ct, st, zp, country, external_id, fbc, fbp, client_ip_address, client_user_agent, lead_id. Anything here wins over the automatic mapping."
      },
      {
        "type": "CHECKBOX",
        "name": "enableEventEnhancement",
        "checkboxText": "Remember user data between events",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Keeps the hashed identifiers in a first party cookie named _gtmeec, and reuses them on later events that carry no user data. A page view after checkout still gets matched. Same cookie that Meta's own template and the Stape tag read and write, so turning it on does not fight what is already there."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "customDataGroup",
    "displayName": "Custom Data",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "autoMapCustomData",
        "checkboxText": "Read ecommerce data from the incoming event",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Turns items into contents and content_ids, and carries value, currency, num_items and order_id across."
      },
      {
        "type": "SELECT",
        "name": "mapItemIdFrom",
        "displayName": "Build content IDs from",
        "selectItems": [
          {
            "value": "item_id",
            "displayValue": "item_id"
          },
          {
            "value": "item_variant",
            "displayValue": "item_variant"
          },
          {
            "value": "item_sku",
            "displayValue": "item_sku"
          }
        ],
        "simpleValueType": true,
        "macrosInSelect": true,
        "defaultValue": "item_id",
        "enablingConditions": [
          {
            "paramName": "autoMapCustomData",
            "paramValue": true,
            "type": "EQUALS"
          }
        ],
        "help": "Has to match the ID scheme in your Meta catalog, or nothing lines up."
      },
      {
        "type": "CHECKBOX",
        "name": "mapDeliveryCategory",
        "checkboxText": "Include delivery category on each item",
        "simpleValueType": true,
        "defaultValue": false,
        "enablingConditions": [
          {
            "paramName": "autoMapCustomData",
            "paramValue": true,
            "type": "EQUALS"
          }
        ],
        "help": "Reads delivery_category from each item and sends in_store, curbside or home_delivery. Useful when pickup and delivery perform differently."
      },
      {
        "type": "TEXT",
        "name": "customDataObject",
        "displayName": "Custom data object",
        "simpleValueType": true,
        "help": "A variable holding an object with custom data fields."
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "customDataList",
        "displayName": "Custom data",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Parameter",
            "name": "name",
            "type": "TEXT",
            "isUnique": true
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT"
          }
        ],
        "newRowButtonText": "Add parameter",
        "help": "Parameter names as Meta writes them: value, currency, order_id, content_name, content_category, content_ids, content_type, contents, num_items, search_string, status, predicted_ltv, net_revenue. Anything here wins over the automatic mapping."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "segmentationGroup",
    "displayName": "Customer Segmentation",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "LABEL",
        "name": "segmentationLabel",
        "displayName": "Tell Meta whether this person is new to your business or already a customer. It feeds new customer acquisition, so campaigns can stop paying to win back people who already bought."
      },
      {
        "type": "SELECT",
        "name": "customerSegmentation",
        "displayName": "Customer segmentation",
        "selectItems": [
          {
            "value": "",
            "displayValue": "Do not send"
          },
          {
            "value": "new_customer_to_business",
            "displayValue": "New customer to business"
          },
          {
            "value": "new_customer_to_business_line",
            "displayValue": "New customer to business line"
          },
          {
            "value": "new_customer_to_product_area",
            "displayValue": "New customer to product area"
          },
          {
            "value": "new_customer_to_medium",
            "displayValue": "New customer to medium"
          },
          {
            "value": "existing_customer_to_business",
            "displayValue": "Existing customer to business"
          },
          {
            "value": "existing_customer_to_business_line",
            "displayValue": "Existing customer to business line"
          },
          {
            "value": "existing_customer_to_product_area",
            "displayValue": "Existing customer to product area"
          },
          {
            "value": "existing_customer_to_medium",
            "displayValue": "Existing customer to medium"
          },
          {
            "value": "customer_in_loyalty_program",
            "displayValue": "Customer in loyalty program"
          }
        ],
        "simpleValueType": true,
        "macrosInSelect": true,
        "defaultValue": "",
        "help": "Pick a fixed value, or point this at a variable that works it out per event."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "cookiesGroup",
    "displayName": "Cookies",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "readFbCookies",
        "checkboxText": "Read _fbc and _fbp from the request",
        "simpleValueType": true,
        "defaultValue": true
      },
      {
        "type": "CHECKBOX",
        "name": "buildFbcFromUrl",
        "checkboxText": "Build _fbc from fbclid in the page URL",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "When the cookie is missing but the URL carries an fbclid, the tag assembles the click ID from it."
      },
      {
        "type": "CHECKBOX",
        "name": "setFbCookies",
        "checkboxText": "Write _fbc and _fbp back to the browser",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Keeps the click ID alive across the visit, which is what a first party cookie is for."
      },
      {
        "type": "CHECKBOX",
        "name": "generateFbp",
        "checkboxText": "Invent a _fbp when the browser never set one",
        "simpleValueType": true,
        "defaultValue": false,
        "help": "Off on purpose. An invented browser ID does not match the one the pixel uses, so it can lower match quality instead of raising it. Turn it on only when there is no Meta Pixel on the site at all."
      },
      {
        "type": "SELECT",
        "name": "cookieDomainSource",
        "displayName": "Cookie domain",
        "selectItems": [
          {
            "value": "auto",
            "displayValue": "Work it out from the request"
          },
          {
            "value": "custom",
            "displayValue": "Set it myself"
          }
        ],
        "simpleValueType": true,
        "macrosInSelect": true,
        "defaultValue": "auto"
      },
      {
        "type": "TEXT",
        "name": "cookieDomain",
        "displayName": "Domain",
        "simpleValueType": true,
        "defaultValue": "auto",
        "enablingConditions": [
          {
            "paramName": "cookieDomainSource",
            "paramValue": "custom",
            "type": "EQUALS"
          }
        ],
        "valueHint": ".example.com"
      },
      {
        "type": "CHECKBOX",
        "name": "useHttpOnlyCookie",
        "checkboxText": "Set the cookies as HttpOnly",
        "simpleValueType": true,
        "defaultValue": false,
        "help": "Blocks the browser pixel from reading them, so leave it off when a Meta Pixel also runs on the site."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "compatGroup",
    "displayName": "Compatibility",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "LABEL",
        "name": "compatLabel",
        "displayName": "Meta's own template expects the web container to rename every field with a prefix. If your container was built that way, leave this on and nothing has to change on the web side."
      },
      {
        "type": "CHECKBOX",
        "name": "acceptFbPrefixes",
        "checkboxText": "Also read x-fb-cd-, x-fb-ud- and x-fb-ck- parameters",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Prefixed values are read first, then the automatic mapping fills the gaps. This is what lets a container move to this tag without editing the web container first."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "consentGroup",
    "displayName": "Consent",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SELECT",
        "name": "adStorageConsent",
        "displayName": "Ad storage consent",
        "selectItems": [
          {
            "value": "not_required",
            "displayValue": "Send the event either way"
          },
          {
            "value": "required",
            "displayValue": "Only send when ad storage is granted"
          }
        ],
        "simpleValueType": true,
        "macrosInSelect": true,
        "defaultValue": "not_required",
        "help": "The default matches how Meta's own template behaves, so switching to this tag does not quietly start dropping events. Switch it to the second option when your consent banner is the authority."
      },
      {
        "type": "CHECKBOX",
        "name": "enableLDU",
        "checkboxText": "Turn on Limited Data Use",
        "simpleValueType": true,
        "defaultValue": false,
        "help": "This is the California rule, not the Brazilian one. Use it when you sell into the United States."
      },
      {
        "type": "SELECT",
        "name": "lduCountry",
        "displayName": "Country",
        "selectItems": [
          {
            "value": "0",
            "displayValue": "Let Meta geolocate"
          },
          {
            "value": "1",
            "displayValue": "United States"
          }
        ],
        "simpleValueType": true,
        "macrosInSelect": true,
        "defaultValue": "0",
        "enablingConditions": [
          {
            "paramName": "enableLDU",
            "paramValue": true,
            "type": "EQUALS"
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "lduState",
        "displayName": "State",
        "simpleValueType": true,
        "valueHint": "1000",
        "enablingConditions": [
          {
            "paramName": "enableLDU",
            "paramValue": true,
            "type": "EQUALS"
          }
        ],
        "help": "Leave it empty to let Meta geolocate. 1000 stands for California."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "advancedGroup",
    "displayName": "More Settings",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "useOptimisticScenario",
        "checkboxText": "Answer before Meta confirms",
        "simpleValueType": true,
        "defaultValue": false,
        "help": "Speeds up the container response, at the cost of the tag always reporting success. Failures still show in the console."
      },
      {
        "type": "TEXT",
        "name": "apiVersionOverride",
        "displayName": "Graph API version",
        "simpleValueType": true,
        "valueHint": "v26.0",
        "help": "Leave it empty to use the version this template ships with. Set it only to move ahead of a template release."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "logsGroup",
    "displayName": "Logs Settings",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "RADIO",
        "name": "logType",
        "displayName": "Console Logging",
        "radioItems": [
          {
            "value": "no",
            "displayValue": "Do not log"
          },
          {
            "value": "debug",
            "displayValue": "Log to console during debug and preview"
          },
          {
            "value": "always",
            "displayValue": "Always log to console"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "debug"
      }
    ]
  }
]

___SANDBOXED_JS_FOR_SERVER___

const computeEffectiveTldPlusOne = require('computeEffectiveTldPlusOne');
const createRegex = require('createRegex');
const decodeUriComponent = require('decodeUriComponent');
const fromBase64 = require('fromBase64');
const toBase64 = require('toBase64');
const generateRandom = require('generateRandom');
const getAllEventData = require('getAllEventData');
const getCookieValues = require('getCookieValues');
const getRequestHeader = require('getRequestHeader');
const getTimestampMillis = require('getTimestampMillis');
const getType = require('getType');
const JSON = require('JSON');
const logToConsole = require('logToConsole');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const Math = require('Math');
const parseUrl = require('parseUrl');
const Promise = require('Promise');
const sendHttpRequest = require('sendHttpRequest');
const setCookie = require('setCookie');
const sha256Sync = require('sha256Sync');
const testRegex = require('testRegex');

const API_VERSION = 'v26.0';
const COOKIE_MAX_AGE = 7776000;

const eventData = getAllEventData();

// Campos de user_data que a Meta espera hasheados.
const HASHED_KEYS = ['em', 'ph', 'fn', 'ln', 'db', 'ge', 'ct', 'st', 'zp', 'country', 'external_id'];

// Campos de user_data que vao crus. Hashear aqui quebra o match.
const RAW_KEYS = ['client_ip_address', 'client_user_agent', 'fbc', 'fbp', 'subscription_id',
  'fb_login_id', 'lead_id', 'anon_id', 'madid', 'page_id', 'page_scoped_user_id',
  'ctwa_clid', 'ig_account_id', 'ig_sid'];

// Campos que sobrevivem no cookie de enriquecimento. So identificador ja
// hasheado entra aqui: nada em texto claro toca o cookie.
const ENHANCEMENT_KEYS = ['em', 'ph', 'fn', 'ln', 'db', 'ge', 'ct', 'st', 'zp',
  'country', 'external_id', 'fb_login_id'];


if (shouldExitEarly()) {
  return data.gtmOnSuccess();
}

const ids = resolveClickAndBrowserIds();
const payload = buildPayload(ids);

log('Wascer Meta CAPI: payload', payload);

if (data.setFbCookies) {
  writeIdCookies(ids);
}

if (data.useOptimisticScenario) {
  sendAll(payload);
  return data.gtmOnSuccess();
}

sendAll(payload).then(data.gtmOnSuccess, data.gtmOnFailure);

// ---------------------------------------------------------------- saida cedo

function shouldExitEarly() {
  if (data.adStorageConsent === 'required' && !isAdStorageGranted()) {
    log('Wascer Meta CAPI: sem consentimento de ad_storage, evento nao enviado.');
    return true;
  }
  const targets = getTargets();
  if (targets.length === 0) {
    log('Wascer Meta CAPI: sem dataset configurado, evento nao enviado.');
    return true;
  }
  return false;
}

function isAdStorageGranted() {
  const consent = eventData.consent_state;
  if (getType(consent) === 'object' && consent.ad_storage !== undefined) {
    return consent.ad_storage === 'granted' || consent.ad_storage === true;
  }
  // Sem sinal de consentimento no evento, trata como concedido.
  return true;
}

function getTargets() {
  const out = [];
  if (data.enableMultiDataset && getType(data.datasetTable) === 'array') {
    data.datasetTable.forEach((row) => {
      if (row.datasetId && row.accessToken) {
        out.push({ datasetId: makeString(row.datasetId), accessToken: makeString(row.accessToken) });
      }
    });
    return out;
  }
  if (data.datasetId && data.accessToken) {
    out.push({ datasetId: makeString(data.datasetId), accessToken: makeString(data.accessToken) });
  }
  return out;
}

// -------------------------------------------------------------- fbc e fbp

function resolveClickAndBrowserIds() {
  let fbc = '';
  let fbp = '';

  if (data.readFbCookies) {
    fbc = firstCookie('_fbc');
    fbp = firstCookie('_fbp');
  }
  if (!fbc) fbc = makeString(eventData._fbc || eventData.fbc || '');
  if (!fbp) fbp = makeString(eventData._fbp || eventData.fbp || '');

  // Um fbclid novo na URL vence o _fbc guardado: quem voltou por um anuncio
  // diferente tem que ser atribuido ao clique novo, nao ao antigo.
  if (data.buildFbcFromUrl) {
    const raw = getUrlParam('fbclid');
    if (raw) {
      const fbclid = decodeUriComponent(raw);
      if (!fbc || lastSegment(fbc) !== fbclid) {
        fbc = 'fb.' + getSubdomainIndex() + '.' + makeString(getTimestampMillis()) + '.' + fbclid;
      }
    }
  }
  if (!fbp && data.generateFbp) {
    fbp = 'fb.' + getSubdomainIndex() + '.' + makeString(getTimestampMillis()) + '.' +
      makeString(generateRandom(1000000000, 2147483647));
  }
  return { fbc: fbc, fbp: fbp };
}

function firstCookie(name) {
  const values = getCookieValues(name);
  return getType(values) === 'array' && values.length > 0 ? makeString(values[0]) : '';
}

function getPageUrl() {
  if (eventData.page_location) return makeString(eventData.page_location);
  const referer = getRequestHeader('referer');
  return referer ? makeString(referer) : '';
}

function getUrlParam(name) {
  const url = getPageUrl();
  if (!url) return '';
  const parsed = parseUrl(url);
  if (!parsed || !parsed.searchParams) return '';
  const value = parsed.searchParams[name];
  return value ? makeString(value) : '';
}

// Indice de subdominio do _fbc e do _fbp. A Meta conta o nivel do dominio em
// que o cookie vive: com = 0, example.com = 1, www.example.com = 2. Como a tag
// grava com domain auto, o cookie vive no dominio registravel, entao o indice e
// a quantidade de rotulos dele menos um. Isso da 1 para example.com e 2 para
// example.com.br, que e o ponto onde contar os rotulos do host se engana.
function getSubdomainIndex() {
  const url = getPageUrl();
  if (!url) return 1;
  const parsed = parseUrl(url);
  if (!parsed || !parsed.hostname) return 1;
  const etldPlusOne = computeEffectiveTldPlusOne(parsed.hostname);
  if (!etldPlusOne) return 1;
  return etldPlusOne.split('.').length - 1;
}

function lastSegment(value) {
  const parts = value.split('.');
  return parts[parts.length - 1];
}

function writeIdCookies(ids) {
  const options = {
    domain: data.cookieDomainSource === 'custom' && data.cookieDomain ? data.cookieDomain : 'auto',
    path: '/',
    secure: true,
    httpOnly: !!data.useHttpOnlyCookie,
    'max-age': COOKIE_MAX_AGE,
    sameSite: 'Lax'
  };
  if (ids.fbc) setCookie('_fbc', ids.fbc, options, false);
  if (ids.fbp) setCookie('_fbp', ids.fbp, options, false);
}

// --------------------------------------------------------------- montagem

function buildPayload(ids) {
  const event = {
    event_name: resolveEventName(),
    event_time: resolveEventTime(),
    action_source: data.actionSource || 'website'
  };

  const eventId = resolveEventId();
  if (eventId) event.event_id = eventId;

  const sourceUrl = getPageUrl();
  if (sourceUrl) event.event_source_url = sourceUrl;

  const referrer = eventData.page_referrer || getRequestHeader('referer');
  if (referrer) event.referrer_url = makeString(referrer);

  if (data.customerSegmentation) event.customer_segmentation = data.customerSegmentation;

  event.user_data = buildUserData(ids);

  const customData = buildCustomData();
  if (!isEmpty(customData)) event.custom_data = customData;

  if (data.enableLDU) {
    event.data_processing_options = ['LDU'];
    event.data_processing_options_country = makeNumber(data.lduCountry || 0);
    event.data_processing_options_state = makeNumber(data.lduState || 0);
  }

  return event;
}

function resolveEventName() {
  return data.eventType === 'custom' ? data.customEventName : data.standardEventName;
}

function resolveEventTime() {
  if (eventData.event_time) return makeNumber(eventData.event_time);
  return Math.round(getTimestampMillis() / 1000);
}

// A dedup da Meta compara event_name e event_id como string exata. Trim so quando
// pedido, porque trimar de um lado so quebra um par que hoje funciona.
function resolveEventId() {
  let id = data.eventId ? makeString(data.eventId) : '';
  if (!id && eventData.event_id) id = makeString(eventData.event_id);
  if (!id && eventData.transaction_id) id = makeString(eventData.transaction_id);
  if (id && data.trimEventId) id = id.trim();
  return id;
}

function buildUserData(ids) {
  const out = {};

  if (data.autoMapUserData) {
    mergeInto(out, readAutoUserData());
  }
  if (data.acceptFbPrefixes) {
    mergeInto(out, readPrefixed('x-fb-ud-'));
    mergeInto(out, readPrefixedCookies());
  }
  if (getType(data.userDataObject) === 'object') {
    mergeInto(out, data.userDataObject);
  }
  mergeInto(out, tableToObject(data.userDataList));

  if (ids.fbc && !out.fbc) out.fbc = ids.fbc;
  if (ids.fbp && !out.fbp) out.fbp = ids.fbp;

  const ip = eventData.ip_override || getRequestHeader('x-forwarded-for');
  if (ip && !out.client_ip_address) out.client_ip_address = firstIp(makeString(ip));

  const ua = eventData.user_agent || getRequestHeader('user-agent');
  if (ua && !out.client_user_agent) out.client_user_agent = makeString(ua);

  const finalized = finalizeUserData(out);

  if (data.enableEventEnhancement) {
    const enhanced = fillFromEnhancementCookie(finalized);
    writeEnhancementCookie(enhanced);
    return enhanced;
  }
  return finalized;
}

// O usuario se identifica uma vez, no checkout ou no login. Os eventos
// seguintes nao carregam nada. Sem isso, page_view e view_item vao sem match.
function fillFromEnhancementCookie(userData) {
  const encoded = firstCookie('_gtmeec') ||
    makeString((getType(eventData.common_cookie) === 'object' ? eventData.common_cookie : {})._gtmeec || '');
  if (!encoded) return userData;

  const json = fromBase64(encoded);
  if (!json) return userData;

  const stored = JSON.parse(json);
  if (getType(stored) !== 'object') return userData;

  ENHANCEMENT_KEYS.forEach((key) => {
    if (!userData[key] && stored[key]) userData[key] = stored[key];
  });
  return userData;
}

function writeEnhancementCookie(userData) {
  const stored = {};
  let has = false;
  ENHANCEMENT_KEYS.forEach((key) => {
    if (userData[key] && getType(userData[key]) === 'string') {
      stored[key] = userData[key];
      has = true;
    }
  });
  if (!has) return;

  setCookie('_gtmeec', toBase64(JSON.stringify(stored)), {
    domain: data.cookieDomainSource === 'custom' && data.cookieDomain ? data.cookieDomain : 'auto',
    path: '/',
    secure: true,
    httpOnly: true,
    'max-age': COOKIE_MAX_AGE,
    sameSite: 'Strict'
  }, false);
}

function readAutoUserData() {
  const out = {};
  const ud = getType(eventData.user_data) === 'object' ? eventData.user_data : {};

  copyFirst(out, 'em', [ud.email_address, ud.email, eventData.email]);
  copyFirst(out, 'ph', [ud.phone_number, ud.phone, eventData.phone_number]);
  copyFirst(out, 'fn', [ud.first_name, eventData.first_name]);
  copyFirst(out, 'ln', [ud.last_name, eventData.last_name]);
  copyFirst(out, 'db', [ud.date_of_birth, ud.db]);
  copyFirst(out, 'ge', [ud.gender, ud.ge]);
  copyFirst(out, 'external_id', [ud.external_id, eventData.user_id, eventData.client_id]);

  const address = getType(ud.address) === 'object' ? ud.address :
    (getType(ud.address) === 'array' && ud.address.length > 0 ? ud.address[0] : {});
  copyFirst(out, 'ct', [address.city, ud.city]);
  copyFirst(out, 'st', [address.region, address.state, ud.region]);
  copyFirst(out, 'zp', [address.postal_code, ud.postal_code]);
  copyFirst(out, 'country', [address.country, ud.country]);
  if (!out.fn) copyFirst(out, 'fn', [address.first_name]);
  if (!out.ln) copyFirst(out, 'ln', [address.last_name]);

  return out;
}

function readPrefixedCookies() {
  const out = {};
  if (eventData['x-fb-ck-fbc']) out.fbc = makeString(eventData['x-fb-ck-fbc']);
  if (eventData['x-fb-ck-fbp']) out.fbp = makeString(eventData['x-fb-ck-fbp']);
  return out;
}

function readPrefixed(prefix) {
  const out = {};
  for (let key in eventData) {
    if (key.indexOf(prefix) === 0) {
      const short = key.substring(prefix.length);
      if (isUsable(eventData[key])) out[short] = eventData[key];
    }
  }
  return out;
}

function finalizeUserData(raw) {
  const out = {};
  for (let key in raw) {
    const value = raw[key];
    if (!isUsable(value)) continue;

    if (indexOf(RAW_KEYS, key) !== -1) {
      out[key] = makeString(value);
      continue;
    }
    if (indexOf(HASHED_KEYS, key) === -1) {
      out[key] = value;
      continue;
    }
    if (getType(value) === 'array') {
      const hashedList = [];
      value.forEach((item) => {
        const one = hashField(key, item);
        if (one) hashedList.push(one);
      });
      if (hashedList.length > 0) out[key] = hashedList;
      continue;
    }
    const hashed = hashField(key, value);
    if (hashed) out[key] = hashed;
  }
  return out;
}

function hashField(key, value) {
  const asString = makeString(value);
  if (isAlreadyHashed(asString)) return asString;
  const normalized = normalize(key, asString);
  return normalized ? sha256Sync(normalized, { outputEncoding: 'hex' }) : '';
}

function isAlreadyHashed(value) {
  return testRegex(createRegex('^[a-f0-9]{64}$', 'i'), value);
}

function normalize(key, value) {
  const trimmed = value.trim().toLowerCase();
  if (!trimmed) return '';

  if (key === 'ph') return digitsOnly(trimmed);
  if (key === 'db') return digitsOnly(trimmed);
  if (key === 'zp') return digitsOnly(trimmed).length > 0 ?
    stripSeparators(trimmed) : stripSeparators(trimmed);
  if (key === 'ct') return lettersAndDigits(trimmed);
  if (key === 'st') return lettersAndDigits(trimmed);
  if (key === 'country') return trimmed.substring(0, 2);
  if (key === 'ge') {
    const first = trimmed.substring(0, 1);
    return first === 'f' || first === 'm' ? first : '';
  }
  return trimmed;
}

function digitsOnly(value) {
  return value.replace(createRegex('[^0-9]', 'g'), '');
}

function stripSeparators(value) {
  return value.replace(createRegex('[\\s-]', 'g'), '');
}

function lettersAndDigits(value) {
  return value.replace(createRegex('[^a-z0-9]', 'g'), '');
}

function firstIp(value) {
  return value.split(',')[0].trim();
}

function buildCustomData() {
  const out = {};

  if (data.autoMapCustomData) {
    mergeInto(out, readAutoCustomData());
  }
  if (data.acceptFbPrefixes) {
    mergeInto(out, readPrefixed('x-fb-cd-'));
  }
  if (getType(data.customDataObject) === 'object') {
    mergeInto(out, data.customDataObject);
  }
  mergeInto(out, tableToObject(data.customDataList));

  return out;
}

function readAutoCustomData() {
  const out = {};
  const ecommerce = getType(eventData.ecommerce) === 'object' ? eventData.ecommerce : {};

  copyFirst(out, 'value', [eventData.value, ecommerce.value]);
  copyFirst(out, 'currency', [eventData.currency, ecommerce.currency]);
  copyFirst(out, 'order_id', [eventData.transaction_id, ecommerce.transaction_id]);
  copyFirst(out, 'search_string', [eventData.search_term]);

  const items = getType(eventData.items) === 'array' ? eventData.items :
    (getType(ecommerce.items) === 'array' ? ecommerce.items : []);

  if (items.length > 0) {
    const contents = [];
    const contentIds = [];
    let totalItems = 0;

    items.forEach((item) => {
      const id = makeString(item[data.mapItemIdFrom] || item.item_id || item.id || '');
      if (!id) return;
      const quantity = item.quantity ? makeNumber(item.quantity) : 1;
      const entry = { id: id, quantity: quantity };
      if (item.price !== undefined) entry.item_price = makeNumber(item.price);
      if (data.mapDeliveryCategory && item.delivery_category) {
        entry.delivery_category = makeString(item.delivery_category);
      }
      contents.push(entry);
      contentIds.push(id);
      totalItems = totalItems + quantity;
    });

    if (contents.length > 0) {
      out.contents = contents;
      out.content_ids = contentIds;
      out.content_type = 'product';
      out.num_items = totalItems;
      if (items[0].item_name && !out.content_name) out.content_name = makeString(items[0].item_name);
      if (items[0].item_category && !out.content_category) {
        out.content_category = makeString(items[0].item_category);
      }
    }
  }
  return out;
}

// ------------------------------------------------------------------ envio

function sendAll(event) {
  const targets = getTargets();
  const version = data.apiVersionOverride ? data.apiVersionOverride : API_VERSION;

  const requests = targets.map((target) => {
    const url = 'https://graph.facebook.com/' + version + '/' + target.datasetId +
      '/events?access_token=' + target.accessToken;

    const body = { data: [event] };
    if (data.testEventCode) body.test_event_code = data.testEventCode;

    return sendHttpRequest(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json' }
    }, JSON.stringify(body)).then((result) => {
      if (result.statusCode >= 200 && result.statusCode < 300) {
        log('Wascer Meta CAPI: dataset ' + target.datasetId + ' aceitou o evento.', result.body);
        return true;
      }
      log('Wascer Meta CAPI: dataset ' + target.datasetId + ' recusou.', result.statusCode, result.body);
      return false;
    });
  });

  return Promise.all(requests).then((results) => {
    const accepted = results.filter((ok) => ok).length;
    if (accepted === 0) return Promise.create((resolve, reject) => reject('nenhum dataset aceitou'));
    return accepted;
  });
}

// ------------------------------------------------------------------ apoio

function tableToObject(rows) {
  const out = {};
  if (getType(rows) !== 'array') return out;
  rows.forEach((row) => {
    if (row.name && isUsable(row.value)) out[row.name] = row.value;
  });
  return out;
}

function mergeInto(target, source) {
  if (getType(source) !== 'object') return;
  for (let key in source) {
    if (isUsable(source[key])) target[key] = source[key];
  }
}

function copyFirst(target, key, candidates) {
  for (let i = 0; i < candidates.length; i++) {
    if (isUsable(candidates[i])) {
      target[key] = candidates[i];
      return;
    }
  }
}

function isUsable(value) {
  if (value === undefined || value === null || value === '') return false;
  if (getType(value) === 'array' && value.length === 0) return false;
  if (getType(value) === 'object' && isEmpty(value)) return false;
  return true;
}

function isEmpty(obj) {
  for (let key in obj) {
    return false;
  }
  return true;
}

function indexOf(list, value) {
  for (let i = 0; i < list.length; i++) {
    if (list[i] === value) return i;
  }
  return -1;
}

function log(a, b, c) {
  if (data.logType === 'no') return;
  if (data.logType === 'debug' && !eventData.debug_mode && !getRequestHeader('x-gtm-server-preview')) return;
  if (c !== undefined) logToConsole(a, b, c);
  else if (b !== undefined) logToConsole(a, b);
  else logToConsole(a);
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://graph.facebook.com/"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "none"
          }
        },
        {
          "key": "readHeaderAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "readBodyAccess",
          "value": {
            "type": 8,
            "boolean": true
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "_fbc"
              },
              {
                "type": 1,
                "string": "_fbp"
              },
              {
                "type": 1,
                "string": "_gtmeec"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_fbc"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_fbp"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_gtmeec"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headersAllowed",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "user-agent"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "referer"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "x-forwarded-for"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "x-gtm-server-preview"
                  }
                ]
              }
            ]
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "none"
          }
        },
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "none"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]

___TESTS___

scenarios: []


___NOTES___

Wascer Meta CAPI, tag de Conversions API para container server.

Rodar os testes: node test/run.js, na raiz do repositorio. O harness em
test/sandbox.js faz shim das APIs do sandbox para executar este arquivo fora
do container.

Pendente antes de publicar na galeria:
  - preencher o bloco ___TESTS___, que e o que o proprio Tag Manager roda
  - conferir a normalizacao de fn e ln com acento contra a doc da Meta
  - Event Type cobre os 17 eventos padrao da Meta mais PageView, lista conferida
    contra a referencia do Meta Pixel. AppendValue fica de fora enquanto
    original_event_data estiver fora de escopo, para nao oferecer opcao quebrada
  - rodar contra um dataset real com test_event_code
  - permissoes de cookie e de header ja declaradas conforme o uso atual

Plano e decisoes: docs/meta-capi-tag-propria.html no repo tags-variables-gtm.

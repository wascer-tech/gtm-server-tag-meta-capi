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
        "type": "SELECT",
        "name": "eventNameSource",
        "displayName": "Event name",
        "selectItems": [
          {
            "value": "automatic",
            "displayValue": "Map from the incoming event"
          },
          {
            "value": "standard",
            "displayValue": "Pick a standard event"
          },
          {
            "value": "custom",
            "displayValue": "Type a custom event name"
          }
        ],
        "simpleValueType": true,
        "macrosInSelect": true,
        "defaultValue": "automatic",
        "help": "Automatic turns GA4 ecommerce names into Meta standard names. purchase becomes Purchase, view_item becomes ViewContent, and so on. Anything it does not recognize is passed through unchanged."
      },
      {
        "type": "SELECT",
        "name": "standardEventName",
        "displayName": "Standard event",
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
        ],
        "simpleValueType": true,
        "macrosInSelect": true,
        "defaultValue": "Purchase",
        "enablingConditions": [
          {
            "paramName": "eventNameSource",
            "paramValue": "standard",
            "type": "EQUALS"
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "customEventName",
        "displayName": "Custom event name",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "valueHint": "SubscribeNewsletter",
        "enablingConditions": [
          {
            "paramName": "eventNameSource",
            "paramValue": "custom",
            "type": "EQUALS"
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
        "name": "mapViewItemListToViewContent",
        "checkboxText": "Treat view_item_list as ViewContent",
        "simpleValueType": true,
        "defaultValue": false
      },
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

const logToConsole = require('logToConsole');

// TODO: implementacao. Este template esta na etapa de superficie de parametros.
// A ordem de trabalho esta em docs/meta-capi-tag-propria.html:
//   1. tabela de conformidade a partir da doc da Meta
//   2. payload real de evento
//   3. bloco ___TESTS___ escrito primeiro
//   4. este arquivo, escrito contra os testes
//
// Enquanto isso a tag nao envia nada. Ela existe para revisar a UI no container.

logToConsole('Wascer Meta CAPI: UI only, no request sent yet.');

data.gtmOnSuccess();


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
  }
]

___TESTS___

scenarios: []


___NOTES___

Wascer Meta CAPI, tag de Conversions API para container server.

Estado: superficie de parametros definida, JS ainda nao implementado.
Plano e decisoes: docs/meta-capi-tag-propria.html no repo tags-variables-gtm.

O bloco de permissoes cobre o que ja e certo. As permissoes de cookie
(get_cookies, set_cookies) e de header (read_request) entram junto com o JS,
para nao declarar acesso que a tag ainda nao usa.


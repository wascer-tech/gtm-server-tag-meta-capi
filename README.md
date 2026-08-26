# Meta CAPI Wascer

A Google Tag Manager **server** tag that sends events to the Meta Conversions
API from your server container. It reads the ecommerce event you already send,
hashes what Meta expects to be hashed, and posts it.

Built by [Wascer](https://wascer.com) for the server containers we host, and free
for anyone to use.

> **Status: not published yet.** The tag builds and sends a real payload, and
> the suite in `test/` covers it. What is still missing is a run against a live
> dataset in Events Manager, and the `___TESTS___` block that Tag Manager runs
> on its own.

## What the template does

1. Builds a Conversions API payload from the event that reaches your server container.
2. Turns GA4 ecommerce names into Meta standard events, and `items` into `contents`.
3. Hashes email, phone, name and address, and leaves already hashed values alone.
4. Reads `_fbc` and `_fbp`, and rebuilds the click ID from `fbclid` when the cookie is gone.
5. Carries the Event ID through, so the browser pixel and this tag are not counted twice.
6. Remembers the hashed identifiers in `_gtmeec`, so a page view after checkout still gets matched.
7. Sends the same event to more than one dataset when you need two ad accounts.

## Installation

1. In your **server** container, open **Templates**, then **Tag Templates**,
   then **New**.
2. Open the three dot menu and choose **Import**.
3. Pick `template.tpl` from this repository and save.
4. Create a tag from the template, fill in the fields below, and attach a trigger.

## Fields

| Group | What it decides |
|---|---|
| Connection | Dataset ID and access token, one or several, plus Action Source and Test Event Code. |
| Event | How the event name is worked out, and the Event ID used for deduplication. |
| User Data | What Meta matches the event against. Automatic mapping, an object, or a table, plus remembering identifiers between events. |
| Custom Data | Value, currency, order and products. Automatic mapping, an object, or a table. |
| Customer Segmentation | Whether this person is new to the business or already a customer. |
| Cookies | Reading and writing `_fbc` and `_fbp`, and the cookie domain. |
| Compatibility | Also read the `x-fb-` prefixed parameters that Meta's own template expects. |
| Consent | Whether ad storage consent gates the event, and Limited Data Use. |
| More Settings | Graph API version, optimistic answer, `view_item_list` handling. |
| Logs Settings | What the tag writes to the container console. |

## Moving from another Conversions API tag

Leave **Compatibility** on. The container that feeds this tag keeps sending its
`x-fb-cd-`, `x-fb-ud-` and `x-fb-ck-` parameters, and nothing has to change on
the web side. The automatic mapping only fills what the prefixes did not carry.

Two defaults are set to match how Meta's own template behaves, so switching
tags does not change your numbers on its own:

- **Ad storage consent** starts at *Send the event either way*.
- **Trim spaces around the Event ID** starts off. Trimming on the server while
  the browser still sends the untrimmed string is what breaks a pair that used
  to deduplicate fine.
- **Remember user data between events** starts on, and reads and writes the same
  `_gtmeec` cookie that Meta's own template and the Stape tag use. A container
  that already had event enhancement keeps it, with the stored identifiers
  intact.

## Running the tests

The template is sandboxed JavaScript, so it only runs inside Tag Manager. The
suite in `test/` gets around that with a small shim of the sandbox APIs, which
means the payload can be checked on a laptop before any container is touched.

```sh
node test/run.js           # 68 checks, no network
node test/run.js --print   # also prints the payload of each scenario
```

No dependencies, no install. The suite reads `template.tpl` itself, so what it
checks is the file that gets imported, not a copy.

## Requirements

A Google Tag Manager **server** container, a Meta dataset, and an access token
generated in Events Manager. Templates published by Wascer are tested against
the container images we host.

## Support

Open an issue in this repository, or reach the team at
[wascer.com](https://wascer.com). If you host your server container with Wascer,
support is included in your plan.

## License

Apache License 2.0. See [LICENSE](LICENSE).

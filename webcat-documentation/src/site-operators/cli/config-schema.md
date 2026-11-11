# `webcat.config.json` Schema

The [manifest](../../concepts.md#manifest) generator expects a WEBCAT config file (commonly `webcat.config.json`
or a JSON equivalent) matching the schema below. The released CLI writes a [schema 0 manifest](../schemas.md#manifest): the browser extension derives the schema 1 fields from it.

| Field | Type | Description |
| --- | --- | --- |
| `app` | string | For open source apps, origin URL of the application being packaged. This is metadata; the format is not validated. Schema 1 replaces it with `source`. |
| `version` | string | Git tag to be used for reproducibility and auditing. |
| `default_csp` | string | Base Content-Security-Policy applied to all assets; see the [CSP guide](../../webapp-developers/CSP.md). |
| `default_index` | string | Index file of each directory, so `/docs/` resolves to `/docs/index.html`; leading `/` is stripped automatically. The extension turns this into a `files` entry per directory. |
| `default_fallback` | string | Absolute path of the document accepted for top-level navigations to paths not in the manifest, such as an error page; must begin with `/`. The extension turns this into `fallback_hashes`; see [fallbacks](../schemas.md#fallbacks). |
| `wasm` | string[] | List (may be empty) of base64url SHA-256 digests for inline WebAssembly modules. `.wasm` files are added automatically during generation. |
| `extra_csp` | Record<string, string> | Per-path CSP overrides. Keys must start with `/`. Example: `{ "/app": "default-src 'none'" }`. May be empty (`{}`). |

Use the JSON example in the [end-to-end example](./end-to-end.md) as a starting point and adjust fields
to match your application.

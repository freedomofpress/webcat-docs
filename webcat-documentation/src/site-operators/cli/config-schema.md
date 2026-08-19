# `webcat.config.json` Schema

The manifest generator expects a Webcat config file (commonly `webcat.config.json`
or a JSON equivalent) matching the schema below:

| Field | Type | Description |
| --- | --- | --- |
| `app` | string | For open source apps, origin URL of the application being packaged. This is metadata; the format is not validated. |
| `version` | string | Git tag to be used for reproducibility and auditing. |
| `default_csp` | string | Base Content-Security-Policy applied to all assets; see the [CSP guide](../../webapp-developers/CSP.md). |
| `default_index` | string | Default index file served when a directory is requested; leading `/` is stripped automatically. |
| `default_fallback` | string | Absolute path served when a file is missing; must begin with `/`. |
| `wasm` | string[] | List (may be empty) of base64url SHA-256 digests for inline WebAssembly modules. `.wasm` files are added automatically during generation. |
| `extra_csp` | Record<string, string> | Per-path CSP overrides. Keys must start with `/`. Example: `{ "/app": "default-src 'none'" }`. May be empty (`{}`). |

Use the JSON example in the [end-to-end example](./end-to-end.md) as a starting point and adjust fields
to match your application.

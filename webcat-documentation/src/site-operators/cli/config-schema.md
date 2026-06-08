# `webcat.config.json` Schema

The manifest generator expects a Webcat config file (commonly `webcat.config.json`
or a JSON equivalent) matching the schema below:

| Field | Type | Description |
| --- | --- | --- |
| `app` | string | Origin URL of the application being packaged. |
| `version` | string | Git tag to be used for reproducibility and auditing. |
| `default_csp` | string | Base Content-Security-Policy applied to all assets. |
| `default_index` | string | Default index file served when a directory is requested; leading `/` is stripped automatically. |
| `default_fallback` | string | Absolute path served when a file is missing. |
| `wasm` | string[] | Optional list of base64url SHA-256 digests for inline WebAssembly modules. `.wasm` files are added automatically during generation. |
| `extra_csp` | Record<string, string> | Optional per-path CSP overrides; keys must start with `/`. | `{}` or `{ "/app": "default-src 'none'" }` |

Use the JSON example in the [end-to-end example](./end-to-end.md) as a starting point and adjust fields
to match your application.

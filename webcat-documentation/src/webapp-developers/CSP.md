# CSP
Due to the the requirements explained in the previous section, WEBCAT enforces certain CSP restrictions, outlined below. In addition to enforcing restrictions on individual policies, WEBCAT disallows multiple `Content-Security-Policy` headers and multiple comma-separated policies in the same header. This may change in the future.

## Restrictions
### default-src
The only allowed source expressions are:
 - `'self'`
 - `'none'`

If the value of the `default-src` directive is not `'none'`, it is required to specify `object-src`, `child-src` or `frame-src`, and `worker-src`. A `default-src` whose source list contains `'none'` but also other source expressions is not treated as `'none'` (See [#99](https://github.com/freedomofpress/webcat/issues/99)).

### script-src, script-src-elem
The only allowed source expressions are:
 - `'none'`
 - `'self'`
 - `'wasm-unsafe-eval'`
 - `'sha256-<digest>'`
 - `'sha384-<digest>'`
 - `'sha512-<digest>'`

### style-src, style-src-elem
The only allowed source expressions are:
 - `'none'`
 - `'self'`
 - `'sha256-<digest>'`
 - `'sha384-<digest>'`
 - `'sha512-<digest>'`
 - `'unsafe-inline'`\*
 - `'unsafe-hashes'`\*

\* These source expressions are currently allowed because all tested applications rely on them. However, when developing or updating an application, it is recommended to avoid using them whenever possible. The long-term goal is to phase out support for these source expressions to improve forward compatibility and tighten policy guarantees.

### object-src
The only allowed source expressions are:
 - `'none'`

The value must be `'none`' if `default-src` is not `'none'`, otherwise it may be omitted.

### frame-src, child-src
The only allowed source expressions are:
 - `'none'`
 - `'self'`
 - `blob:`
 - `data:`
 - `<host>`\*
 - `<URL>`\*

\* Host and URL sources must also be enrolled in WEBCAT. At manifest parsing, it is checked whether any external origin is enrolled, or the validation fails. Upon loading, any external origin is fully validated.

Either `frame-src` or `child-src` must be set if `default-src` is not `'none'`, otherwise it may be omitted.

### worker-src
The only allowed attributes are:
 - `'none'`
 - `'self'`

The `worker-src` directive must be set if `default-src` is not `'none'`, otherwise it can be omitted.

### Everything else (img-src, connect-src, etc.)
Other directives do not currently have limitations.

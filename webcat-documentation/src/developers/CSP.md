# CSP
Due to the the requirements explained in the previous section, WEBCAT has some CSP requirements, outlined below. In addition to the limitations of the CSP policy itself, due to the complexity derived from different browser parsing behaviors, WEBCAT does not allow multiple `Content-Security-Policy` headers nor multiple comma-separated policies in the same header. This might change in the future, but it is currently not supported.

## Restrictions
### default-src
Only allowed attributes are:
 - `self`
 - `none`

If `default-src` is not `none`, than it is required to specify `object-src`, `child-src` or `frame-src` and `worker-src`. A `default-src` that contains `none` but also other keywords is not treated as `none` (#99)[https://github.com/freedomofpress/webcat/issues/99].

### script-src, script-src-elem
Only allowed attributes are:
 - `none`
 - `self`
 - `wasm-unsafe-eval`
 - `sha256-xxx`
 - `sha384-xxx`
 - `sha512-xxx`

### style-src, style-src-elem
Only allowed attirbutes are:
 - `none`
 - `self`
 - `sha256-xxx`
 - `sha384-xxx`
 - `sha512-xxx`
 - `unsafe-inline`*
 - `unsafe-hashes`*

The source expression marked with `*` are currently allowed because all tested applications rely on it. However, when developing or updating an application, it is recommended to avoid using it whenever possible. The long-term goal is to phase out support for these source expressions to improve forward compatibility and tighten policy guarantees.

### object-src
Only allowed attirbutes are:
 - `none`

Must be `'none`' if `default-src` is not `'none'`, otherwise it can be omitted.

### frame-src, child-src
Only allowed attirbutes are:
 - `none`
 - `self`
 - `blob:`
 - `data:`
 - `<external sources>`*

* external sources needs to be enrolled in WEBCAT too. At manifest parsing, it is checked whether any external origin is enrolled, or the validation fails. Then, upon loading, any external origin is fully validated th same as the main_frame.

Either one of the two must be set if `default-src` is not `'none'`, otherwise it can be omitted.

### worker-src
Only allowed attirbutes are:
 - `none`
 - `self`

Must be set if `default-src` is not `'none'`, otherwise it can be omitted.

### Everything else (img-src, connect-src, etc)
Everything else does not currently have limitations.

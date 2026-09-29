# CSP
Due to the the requirements explained in the previous section, WEBCAT enforces certain CSP restrictions, outlined below. In addition to enforcing restrictions on individual policies, WEBCAT disallows multiple `Content-Security-Policy` headers and multiple comma-separated policies in the same header. This may change in the future.

Hash source expressions (`'sha256-<digest>'`, `'sha384-<digest>'`, `'sha512-<digest>'`) are accepted where listed below. Nonces (`'nonce-<value>'`) are never accepted, because their value cannot be covered by the manifest signature.

## Restrictions
### default-src
The only allowed source expressions are:
 - `'self'`
 - `'none'`

If the value of the `default-src` directive is not `'none'`, it is required to specify `script-src`, `style-src`, `object-src` and `worker-src`. A `default-src` whose source list contains `'none'` but also other source expressions is not treated as `'none'` (See [#99](https://github.com/freedomofpress/webcat/issues/99)).

### script-src, script-src-elem
The only allowed source expressions are:
 - `'none'`
 - `'self'`
 - `'wasm-unsafe-eval'`
 - `'sha256-<digest>'`
 - `'sha384-<digest>'`
 - `'sha512-<digest>'`

All scripts must either be served from the enrolled origin, and thus be covered by the manifest, or be inlined with a hash. Loading scripts from other origins, even enrolled ones, is not supported. `script-src-elem` is required only if `script-src` is absent and `default-src` is not `'none'`.

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

`style-src-elem` is required only if `style-src` is absent and `default-src` is not `'none'`.

### object-src
The only allowed source expressions are:
 - `'none'`

The value must be `'none'` if `default-src` is not `'none'`, otherwise it may be omitted.

### frame-src, child-src
These directives are not restricted. Any value is accepted, and they may be omitted.

WEBCAT adds the `Origin-Agent-Cluster: ?1` header to every enrolled document. Frames are isolated from the embedding page by the same-origin policy, also when they are on the same site.

A framed origin that is enrolled is verified under its own manifest. A framed origin that is not enrolled is not verified.

Do not send an `Origin-Agent-Cluster` header with a value other than `?1` for enrolled documents. Such responses are blocked.

Set the `sandbox` attribute on frames that embed unverified content, such as CAPTCHAs, third-party players or payment widgets. Grant only the flags needed, for example `sandbox="allow-scripts"`, and never `allow-same-origin` for content you do not control. Exchange data with frames through `postMessage` with an explicit origin check.

### worker-src
The only allowed source expressions are:
 - `'none'`
 - `'self'`

The `worker-src` directive must be set if `default-src` is not `'none'`, otherwise it can be omitted.

### Everything else (img-src, connect-src, etc.)
Other directives do not currently have limitations.

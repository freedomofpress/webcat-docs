# CSP
WEBCAT verifies that everything a page executes is covered by the signed manifest. The Content Security Policy enforces this at runtime: it prevents the page from loading scripts that are not in the manifest, from executing code generated at runtime with `eval()`, and from starting workers from `blob:` or `data:` URLs. WEBCAT therefore restricts which policies a manifest may declare and verifies that the server sends them.

The authoritative list of rules is the [CSP section of the specification](https://github.com/freedomofpress/webcat-spec/blob/main/csp.md). This page describes how the rules are applied and how to write a compliant policy.

## How WEBCAT applies your policy

A manifest contains one mandatory policy, `default_csp`, and optionally a map of path-specific policies, `extra_csp`. Both are configured in `webcat.config.json` (see the [schema](../site-operators/cli/config-schema.md)).

**At manifest load.** Every policy in the manifest is validated against the rules below. A policy that violates a rule invalidates the entire manifest and the site does not load. The error page shows `ERR_WEBCAT_MANIFEST_DEFAULT_CSP_INVALID` or `ERR_WEBCAT_MANIFEST_EXTRA_CSP_INVALID`, or `ERR_WEBCAT_MANIFEST_EXTRA_CSP_MALFORMED` if `extra_csp` is not an object mapping paths to strings.

**On every response.** Each response from the enrolled origin must carry a `Content-Security-Policy` header that matches the manifest policy for its path character for character. Whitespace, directive ordering and quoting are all significant. A different header gives `ERR_WEBCAT_CSP_MISMATCH`; a missing header gives `ERR_WEBCAT_HEADERS_MISSING_CRITICAL`. Responses served from the browser cache are exempt from the header check because Firefox does not always expose their headers to extensions. The browser still enforces the policy on them.

Send a single policy. Manifest policies must not contain commas. If an intermediary, for example a browser extension such as NoScript, appends a further policy to the header, WEBCAT compares only the first policy. The browser enforces all of them.

**Which policy applies to a path.** WEBCAT looks for the request path as an exact key in `extra_csp`, then for the longest `extra_csp` key that is a prefix of the path, and falls back to `default_csp`. A request for `/` is matched as `default_index`. Keys in `extra_csp` are plain string prefixes: `"/admin"` also covers `/admin-help.html`, so terminate keys with `/` to denote a directory.

## Restrictions

Hash source expressions (`'sha256-<digest>'`, `'sha384-<digest>'`, `'sha512-<digest>'`) are accepted where listed below. Nonces (`'nonce-<value>'`) are never accepted, because their value cannot be covered by the manifest signature. Multiple `Content-Security-Policy` headers and comma-separated policy lists are not accepted in the manifest.

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

All scripts must either be served from the enrolled origin, and thus be covered by the manifest, or be inlined with a hash. Loading scripts from other origins, even enrolled ones, is not supported. `'wasm-unsafe-eval'` is allowed because WebAssembly bytecode is verified separately against the `wasm` hashes in the manifest. `script-src-elem` is required only if `script-src` is absent and `default-src` is not `'none'`.

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

WEBCAT adds the `Origin-Agent-Cluster: ?1` header to every enrolled document. This requests origin-keyed agent clustering, so frames are isolated from the embedding document by origin even when they belong to the same site.

A framed origin that is enrolled is verified under its own manifest. A framed origin that is not enrolled is not verified.

Do not send an `Origin-Agent-Cluster` header with a value other than `?1` for enrolled documents. Such responses are blocked.

Set the `sandbox` attribute on frames that embed unverified content, such as CAPTCHAs, third-party players or payment widgets, and exchange data with them through `postMessage`. Worked examples are in [Embedding untrusted content](./embedding-untrusted-content.md).

### worker-src
The only allowed source expressions are:
 - `'none'`
 - `'self'`

The `worker-src` directive must be set if `default-src` is not `'none'`, otherwise it can be omitted. Setting it explicitly is recommended in all cases, because browsers fall back to `child-src`, which is unrestricted, when it is absent.

### Everything else (img-src, connect-src, etc.)
Other directives do not currently have limitations.

## Writing a policy

Start from `default-src 'none'` and add only the sources the application requires. A typical policy for a single-page application:

```
default-src 'none'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self'; object-src 'none'; worker-src 'self'; img-src 'self' blob: data:; font-src 'self'; connect-src 'self'; frame-ancestors 'self'
```

Directive by directive:

 - `default-src 'none'`: no resource loads unless a more specific directive permits it.
 - `script-src 'self' 'wasm-unsafe-eval'`: scripts only from the enrolled origin, which the manifest covers; omit `'wasm-unsafe-eval'` if the application does not use WebAssembly.
 - `style-src 'self'`: stylesheets only from the enrolled origin. Add `'unsafe-inline'` only if the framework injects inline styles that cannot be avoided.
 - `object-src 'none'`: disables plugins. Required whenever `default-src` is not `'none'`. Stating it in all cases is harmless.
 - `worker-src 'self'`: workers only from the enrolled origin, where their scripts are verified like any other script.
 - `img-src`, `font-src`, `connect-src`: not restricted by WEBCAT. Limit them to the sources the application uses. `connect-src` determines which API endpoints the application can call.
 - `frame-ancestors 'self'`: not restricted by WEBCAT, but prevents other sites from framing the application.
 - `frame-src`: not restricted by WEBCAT, but falls back to `default-src 'none'` in this policy. List the origins of any embedded frames, see [Embedding untrusted content](./embedding-untrusted-content.md).

Then:

 - Use the identical string in `webcat.config.json` and in the server or CDN configuration. Generating one from the other avoids transcription errors.
 - Verify that no intermediary between the origin server and the browser rewrites the header. Some CDNs and security proxies append or reorder directives, which changes the string and fails the match.
 - Use `extra_csp` only when a path requires a different policy. Every entry is validated against the same rules and cannot be used to relax them.

## Setting the header

Every response from the enrolled origin must carry the header, including error pages and static assets. Set it at the server or hosting platform level rather than per page.

**GitHub Pages** does not support custom response headers, so a site hosted there cannot send a CSP and cannot be enrolled. Either proxy the site through Cloudflare and set the header there, or use a different host.

**Cloudflare Pages**: add a `_headers` file to the build output directory. Per-path rules map directly to `extra_csp` entries. [Instructions](https://developers.cloudflare.com/pages/configuration/headers/).

```
/*
  Content-Security-Policy: default-src 'none'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self'; object-src 'none'; worker-src 'self'; img-src 'self' blob: data:; font-src 'self'; connect-src 'self'; frame-ancestors 'self'
```

**Cloudflare (proxied sites)**: for any origin behind the Cloudflare proxy, including GitHub Pages, add a response header transform rule that sets `Content-Security-Policy`. [Instructions](https://developers.cloudflare.com/rules/transform/response-header-modification/).

**Netlify**: same `_headers` file format, or a `[[headers]]` block in `netlify.toml`. [Instructions](https://docs.netlify.com/routing/headers/).

**Vercel**: a `headers` array in `vercel.json`. [Instructions](https://vercel.com/docs/project-configuration#headers). See the Tinfoil deployment in [Examples](./examples.md) for a working setup.

**nginx**: in the `server` block. `always` includes error responses. An `add_header` inside a `location` block replaces all inherited ones, so repeat the directive there. [Instructions](https://nginx.org/en/docs/http/ngx_http_headers_module.html#add_header).

```
add_header Content-Security-Policy "default-src 'none'; script-src 'self'; ..." always;
```

**Apache**: with `mod_headers`, in the virtual host or `.htaccess`. `always` includes error responses. [Instructions](https://httpd.apache.org/docs/2.4/mod/mod_headers.html#header).

```
Header always set Content-Security-Policy "default-src 'none'; script-src 'self'; ..."
```

**Caddy**: a `header` directive in the site block. [Instructions](https://caddyserver.com/docs/caddyfile/directives/header).

```
header Content-Security-Policy "default-src 'none'; script-src 'self'; ..."
```

**Traefik**: a `headers` middleware attached to the router. [Instructions](https://doc.traefik.io/traefik/middlewares/http/headers/).

```
http:
  middlewares:
    webcat-csp:
      headers:
        contentSecurityPolicy: "default-src 'none'; script-src 'self'; ..."
```

Verify the served header against the configuration file before enrolling:

```
curl -sI https://example.com/ | grep -i content-security-policy
```

## Common rejections

| Error code | Usual cause |
|---|---|
| `ERR_WEBCAT_MANIFEST_DEFAULT_CSP_INVALID` | A nonce, `'unsafe-eval'`, `'unsafe-inline'` or `'strict-dynamic'` in `script-src`; a host in `script-src`; `default-src 'self'` without `script-src`, `style-src`, `object-src` and `worker-src`; a comma in the policy. |
| `ERR_WEBCAT_MANIFEST_EXTRA_CSP_INVALID` | The same, in one of the `extra_csp` entries. |
| `ERR_WEBCAT_MANIFEST_EXTRA_CSP_MALFORMED` | `extra_csp` is not an object whose keys are paths and values are strings. |
| `ERR_WEBCAT_CSP_MISMATCH` | The served header differs from the manifest policy: different whitespace or ordering, a CDN that edits the header, or a path that matched a different `extra_csp` prefix than intended. |
| `ERR_WEBCAT_HEADERS_MISSING_CRITICAL` | The response has no `Content-Security-Policy` header. |

The full list of error codes is in the [user documentation](../for-users.md#error-codes).

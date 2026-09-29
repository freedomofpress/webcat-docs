# CSP
WEBCAT verifies that everything a page executes was covered by the signed manifest. The Content Security Policy is what makes that hold at runtime: it stops the page from loading scripts that are not in the manifest, from running code built at runtime with `eval()`, and from starting workers from `blob:` or `data:` URLs. For this to work, WEBCAT restricts which policies a manifest may declare and checks that the server really sends them.

The authoritative list of rules is the [CSP section of the specification](https://github.com/freedomofpress/webcat-spec/blob/main/csp.md). This page explains how the rules are applied and how to write a policy that satisfies them.

## How WEBCAT applies your policy

Your manifest carries one mandatory policy, `default_csp`, and optionally a map of path-specific policies, `extra_csp`. Both are set in `webcat.config.json` (see the [schema](../site-operators/cli/config-schema.md)).

**At manifest load.** Every policy in the manifest is validated against the rules below. A policy that breaks a rule fails the whole manifest, and the site does not load. The error page shows `ERR_WEBCAT_MANIFEST_DEFAULT_CSP_INVALID` or `ERR_WEBCAT_MANIFEST_EXTRA_CSP_INVALID`, or `ERR_WEBCAT_MANIFEST_EXTRA_CSP_MALFORMED` if `extra_csp` is not an object mapping paths to strings.

**On every response.** Each response from the enrolled origin must carry a `Content-Security-Policy` header that matches the manifest policy for its path character for character. Whitespace, ordering and quoting all count. A different header gives `ERR_WEBCAT_CSP_MISMATCH`; a missing header gives `ERR_WEBCAT_HEADERS_MISSING_CRITICAL`. Responses served from the browser cache are exempt from the header check, since Firefox does not always expose their headers to extensions; the policy still applies to them.

Send a single policy. Manifest policies must not contain commas. If something between the server and the page appends a further policy to the header, for example a browser extension such as NoScript, WEBCAT compares only the first policy; the browser still enforces all of them.

**Which policy applies to a path.** WEBCAT looks for the request path as an exact key in `extra_csp`, then for the longest `extra_csp` key that is a prefix of the path, and falls back to `default_csp`. A request for `/` is matched as `default_index`. Keys in `extra_csp` are plain string prefixes: `"/admin"` also covers `/admin-help.html`, so end keys with `/` when you mean a directory.

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

WEBCAT adds the `Origin-Agent-Cluster: ?1` header to every enrolled document. Frames are isolated from the embedding page by the same-origin policy, also when they are on the same site.

A framed origin that is enrolled is verified under its own manifest. A framed origin that is not enrolled is not verified.

Do not send an `Origin-Agent-Cluster` header with a value other than `?1` for enrolled documents. Such responses are blocked.

Set the `sandbox` attribute on frames that embed unverified content, such as CAPTCHAs, third-party players or payment widgets. Grant only the flags needed, for example `sandbox="allow-scripts"`, and never `allow-same-origin` for content you do not control. Exchange data with frames through `postMessage` with an explicit origin check.

### worker-src
The only allowed source expressions are:
 - `'none'`
 - `'self'`

The `worker-src` directive must be set if `default-src` is not `'none'`, otherwise it can be omitted. Set it explicitly anyway: when it is absent, browsers fall back to `child-src`, which is unrestricted.

### Everything else (img-src, connect-src, etc.)
Other directives do not currently have limitations.

## Writing a policy

Start from `default-src 'none'` and add only what the application needs. A typical policy for a single-page application:

```
default-src 'none'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self'; object-src 'none'; worker-src 'self'; img-src 'self' blob: data:; font-src 'self'; connect-src 'self'; frame-ancestors 'self'
```

Directive by directive:

 - `default-src 'none'`: nothing loads unless a directive below allows it.
 - `script-src 'self' 'wasm-unsafe-eval'`: scripts only from the enrolled origin, which the manifest covers; drop `'wasm-unsafe-eval'` if the app has no WebAssembly.
 - `style-src 'self'`: stylesheets only from the enrolled origin. Add `'unsafe-inline'` only if the framework injects inline styles and you cannot avoid it.
 - `object-src 'none'`: no plugins. Required whenever `default-src` is not `'none'`, harmless to state always.
 - `worker-src 'self'`: workers only from the enrolled origin, where their scripts are verified like any other script.
 - `img-src`, `font-src`, `connect-src`: unrestricted by WEBCAT, so tighten them to what the app uses. `connect-src` decides which API endpoints the app can call.
 - `frame-ancestors 'self'`: not restricted by WEBCAT, but stops other sites from framing the app.

Then:

 - Put the exact same string in `webcat.config.json` and in the server or CDN configuration. Generate one from the other rather than typing it twice.
 - Check that nothing between the origin server and the browser rewrites the header. Some CDNs and security proxies append or reorder directives, which changes the string and fails the match.
 - Use `extra_csp` only when a path really needs a different policy. Every entry is validated by the same rules, so it cannot be used to relax them.

## Setting the header

Every response from the enrolled origin needs the header, including error pages and static assets, so set it at the server or hosting platform level, not per page.

**GitHub Pages** does not support custom response headers, so a site hosted there cannot carry a CSP and cannot be enrolled. Proxy it through Cloudflare and set the header there, or host elsewhere.

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

Check the result against the config file before enrolling:

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

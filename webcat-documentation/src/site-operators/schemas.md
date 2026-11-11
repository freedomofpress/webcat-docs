# Manifest and enrollment schemas

The two documents a site serves, the [manifest](../concepts.md#manifest) and the [enrollment information](../concepts.md#enrollment-information), are versioned. The manifest carries `manifest_schema` and the enrollment `enrollment_schema`, both integers. A document without the field is **schema 0**: it predates versioning. The current version of both is **schema 1**. The authoritative definitions are in the [WEBCAT specification](https://github.com/freedomofpress/webcat-spec): [manifest.md](https://github.com/freedomofpress/webcat-spec/blob/main/manifest.md) and [server.md](https://github.com/freedomofpress/webcat-spec/blob/main/server.md).

**Where things stand.** The [browser extension](../concepts.md#browser-extension) from 3.2.0 reads both schemas and derives the schema 1 fields from a schema 0 document on load. Its minimum accepted schema is currently 0; once it is raised, a schema 0 document fails with `ERR_WEBCAT_MANIFEST_SCHEMA_DEPRECATED` or `ERR_WEBCAT_ENROLLMENT_SCHEMA_DEPRECATED` and the site must publish a newer one. Extensions before 3.2.0 only understand schema 0. The released [webcat-cli](./cli/) (0.1.3) writes schema 0 documents; the transition is tracked in [webcat#263](https://github.com/freedomofpress/webcat/issues/263) and [webcat-cli#22](https://github.com/freedomofpress/webcat-cli/pull/22). In general, site operators do not migrate by hand: the CLI handles schema migrations automatically when a manifest is re-signed or an enrollment is renewed, where that is applicable.

## Canonicalization and hashes

The schema field is part of the signed and hashed content, and it selects the canonical JSON form the hash is computed over:

| Schema | Canonical JSON |
| --- | --- |
| 1 | [RFC 8785 (JCS)](https://www.rfc-editor.org/rfc/rfc8785) |
| 0 | [OLPC canonical JSON](https://theupdateframework.github.io/specification/latest/#metaformat); verifiers accept a schema 0 document if its hash matches under either form |

Adding the schema field to an existing document changes its hash. A manifest needs new signatures, and an enrollment needs a new enrollment on the [enrollment infrastructure](../concepts.md#enrollment-infrastructure).

## Manifest

### Schema 1

```json
{
  "manifest_schema": 1,
  "version": "1.4.0",
  "source": "https://github.com/example/app",
  "artifact": "https://github.com/example/app/releases/download/${version}/webcat-${version}.tar.gz",
  "default_csp": "default-src 'none'; script-src 'self'; style-src 'self'",
  "extra_csp": {},
  "files": {
    "/": "<hash of index.html>",
    "/index.html": "<hash of index.html>",
    "/docs/": "<hash of docs/index.html>",
    "/docs/index.html": "<hash of docs/index.html>",
    "/404.html": "<hash of 404.html>"
  },
  "fallback_hashes": ["<hash of 404.html>"],
  "wasm": [],
  "timestamp": "<Sigsum cosigned tree head, Sigsum enrollments only>"
}
```

| Field | Required | Description |
| --- | --- | --- |
| `manifest_schema` | yes | `1`. |
| `version` | yes | Semantic version of the app. With `source` set, it must be a git tag in that repository. |
| `default_csp` | yes | CSP for every path not covered by `extra_csp`; see the [CSP guide](../webapp-developers/CSP.md). |
| `extra_csp` | yes, may be `{}` | Path prefix to CSP, longest prefix wins. |
| `files` | yes | Absolute path to base64url SHA-256. A directory path ending in `/`, including `/` itself, is listed with the hash of the document the server serves for it. |
| `wasm` | yes, may be `[]` | Hashes of WebAssembly binaries. |
| `timestamp` | Sigsum only | Sigsum cosigned tree head; omitted for Sigstore. |
| `fallback_hashes` | no | Hashes accepted at any path on a top-level navigation, see below. |
| `source` | no | Git repository the app is built from; omitted for closed-source apps. |
| `artifact` | no | URL template of the release archive, `${version}` substituted. |

### Schema 0

A schema 0 manifest has no `manifest_schema` and no directory entries in `files`. Instead of `fallback_hashes`, `source` and `artifact` it carries:

| Field | Description | Schema 1 equivalent |
| --- | --- | --- |
| `default_index` | Bare file name appended to a directory path, for example `index.html`, so `/docs/` resolves to `/docs/index.html`. | A `files` entry per directory. |
| `default_fallback` | Absolute `files` key served for top-level navigations to paths not in `files`. | `fallback_hashes` holding that file's hash. |
| `app` | Origin URL of the app, metadata only. | `source`. |

Extensions from 3.2.0 derive the schema 1 fields from these on load. Extensions before 3.2.0 require both `default_index` and `default_fallback` and reject a manifest where they do not resolve to a `files` entry. A manifest with `manifest_schema` must not carry any of the three.

### Fallbacks

A fallback is a document the extension accepts at any path on a top-level navigation, such as the catch-all page of a single-page app or a custom error page. On a navigation, the response passes if its hash matches the path's `files` entry or any entry in `fallback_hashes`. Subresources, including favicons, never fall back: they must match their own `files` entry. A 404 response must therefore be one of the fallback documents, with the [required headers](../webapp-developers/requirements.md).

Each fallback must also be served at `/.well-known/webcat/hashes/<hash>`, so auditors can find what the manifest accepts by its hash. The extension does not check that path.

## Enrollment

### Schema 1

Sigsum:

```json
{
  "type": "sigsum",
  "enrollment_schema": 1,
  "signers": ["<base64url Ed25519 public key>"],
  "threshold": 1,
  "policy": "<base64url compiled Sigsum policy>",
  "max_age": 15552000,
  "logs": { "<base64url log public key>": "https://log.example.org/" }
}
```

Sigstore:

```json
{
  "type": "sigstore",
  "enrollment_schema": 1,
  "trusted_root": { "...": "..." },
  "claims": { "1.3.6.1.4.1.57264.1.8": "https://token.actions.githubusercontent.com" },
  "max_age": 15552000
}
```

See the [CLI enrollment reference](./cli/enrollment.md) for how to produce these, and the spec's [server.md](https://github.com/freedomofpress/webcat-spec/blob/main/server.md) for every field.

### Schema 0

A schema 0 enrollment has no `enrollment_schema`. A Sigsum one additionally carries `cas_url`, the base URL of a content-addressable store, which the [well-known directory](https://github.com/freedomofpress/webcat-spec/blob/main/server.md#1-well-known-directory) replaces. Everything else is as in schema 1, including the required `logs` map. Because `cas_url` is part of the hashed content, a schema 0 enrollment must keep it unchanged while in use. New enrollments must not include it.

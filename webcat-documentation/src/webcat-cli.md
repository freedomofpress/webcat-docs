# WEBCAT CLI

Utilities for creating, validating, and packaging WEBCAT enrollments and manifests.
## Quick Start

This utility, together with the GitHub Actions provided in the same repository, can be used to quickly integrate and enroll a web application or domain into WEBCAT. Below are the recommended steps.

## Prepare the web application for compatibility

Before anything else, you should evaluate whether your website or web application is compatible with WEBCAT. There are a few strict requirements:

* The frontend **must be fully static** (i.e., no server-generated HTML, JavaScript, or CSS).
* **No inline JavaScript** is allowed.
* A **Content Security Policy (CSP)** must be provided via an HTTP header and must satisfy specific constraints (see: [CSP Guide](https://github.com/freedomofpress/webcat/blob/main/docs/DeveloperGuide.md), [explanation blog post](https://securedrop.org/news/webcat-towards-auditable-web-application-runtimes/)).

See the following examples and porting guides (outdated):
 - [Cryptpad](https://github.com/freedomofpress/webcat/tree/main/apps/cryptpad)
 - [Element](https://github.com/freedomofpress/webcat/tree/main/apps/element)
 - [Globaleaks](https://github.com/freedomofpress/webcat/tree/main/apps/globaleaks)
 - [Jitsi](https://github.com/freedomofpress/webcat/tree/main/apps/jitsi)

At the end, you should have compiled a `webcat.config.json` base file for your use case.

## Decide and prepare enrollment information

A WEBCAT manifest describes a web application by listing its files, cryptographic hashes, CSP policies, and additional metadata useful for auditability. But how is this information verified?

Manifests are authenticated using either **Sigsum** or **Sigstore** signatures. The metadata required to validate these signatures or attestations must be **registered beforehand** with WEBCAT’s distributed validation system.

Changes to enrollment information are:

* Transparently logged
* Auditable
* Subject to a delay (cool-down window)

Keep this in mind: if you make a mistake, you may need to wait before updating the enrollment again.

The first decision you must make is whether to use **Sigsum** or **Sigstore**.

### Choosing Sigsum

[Sigsum](https://www.sigsum.org/), developed by [Glasklar Teknik](https://www.glasklarteknik.se/), provides:

* Compact Ed25519 signatures
* Easy offline signing
* Threshold signing support in WEBCAT

You can choose among multiple transparency logs and witness policies, or even run your own witness if you want to define your own trust roots.

Sigsum is generally the better choice if:

* You want offline, manual signing
* You do not want to depend on GitHub or other centralized infrastructure

However, due to current tooling limitations, Sigsum is less convenient for fully automated deployment workflows.

To learn more about Sigsum and how to write a policy, see Sigsum's [_Getting Started_](https://www.sigsum.org/getting-started/) guide.

### Choosing Sigstore

If you choose Sigstore, WEBCAT provides GitHub Actions that support automated deployments.

> [!WARNING]
> Sigstore support is still a work in progress. Claim-based enrollment constraints are supported.

In theory, WEBCAT also supports a bring-your-own Sigstore deployment. This is not documented here due to its complexity. This guide assumes you are using the Sigstore [_Public Good_ instance](https://openssf.org/blog/2023/10/03/running-sigstore-as-a-managed-service-a-tour-of-sigstores-public-good-instance/), the same one used by GitHub and public container registries.

The Sigstore workflow consists of two actions:

* Enrollment Update Action - [Source](https://github.com/freedomofpress/webcat-cli/blob/main/.github/workflows/sigstore-enrollment-sync.yml) / [Example usage](https://github.com/freedomofpress/webcat-demo-test/blob/main/.github/workflows/sync-sigstore-enrollment.yml)

  * Fetches the latest trust material using TUF
  * Updates enrollment information if changes are detected
  * Submits the updated enrollment for re-evaluation by the distributed system
    *(This submission step will soon be integrated directly into the CLI.)*

> [!CAUTION]
> Sigstore enrollments support claim-based constraints using certificate extension OIDs.

* Manifest Update Action - [Example Usage](https://github.com/freedomofpress/webcat-demo-test/blob/main/.github/workflows/generate-sign-sigstore-manifest.yaml)

  * Generates, signs, and bundles a WEBCAT manifest

See the `webcat-demo-test` repository for a complete, end-to-end example of this flow. Note: due to how the Sigstore is claimed in Github Action, this has to be copied in the target repository and should not be invoked directly from the webcat0-cli one.

## Using the CLI

### If you are using Sigsum

Take a look at [`demo.sh`](./demo.sh) or the [end-to-end example] below.

[end-to-end example]: #end-to-end-example-based-on-demosh

### If you are using Sigstore

Refer to the GitHub Actions described above.

## Requirements

- Node.js 20 or newer.
- `sigsum-submit` must be available on your `$PATH` for `manifest sign` operations. (See the [installation instructions][#installation] below.)
- A Sigsum trust policy and keypair for signing manifests.
- An OIDC identity token in the environment (CI-supported) or interactive login for `manifest sign --type sigstore`.

## Installation

```sh
npm install @freedomofpress/webcat-cli
```

To run the installed CLI:

```sh
npx webcat --help
```

Sigsum needs to be installed separately, as it currently is only available in Go binaries:

```
go install sigsum.org/sigsum-go/cmd/sigsum-key@latest
go install sigsum.org/sigsum-go/cmd/sigsum-submit@latest
```

By default, these binaries will be available in `$HOME/go/bin`.

## Enrollment helpers

The `enrollment` namespace manages Sigsum or Sigstore enrollment payloads. Sigsum enrollments
are the default; use `--type sigstore` along with Sigstore claim constraints (`--claim`
and/or compatibility flags `--issuer` + `--identity`) and either `--trusted-root` or
`--community-trusted-root` to build Sigstore enrollments.

| Command | Purpose |
| --- | --- |
| `enrollment create` | Compile a Sigsum policy file and create a normalized enrollment JSON document. |
| `enrollment canonicalize` | Canonicalize an enrollment JSON document using canonical JSON rules. |
| `enrollment hash` | Canonicalize and SHA-256 hash an enrollment, outputting a base64url digest. |

Example – hash the sample enrollment definition:

```sh
npx webcat enrollment hash -i examples/enrollment.json
# => TSNydkDZBv6QNZ3m7ZuBP9fFj0TD6hHDmzcwu9ulK3A
```

The canonicalized document (useful for audits) can be produced with:

```sh
npx webcat enrollment canonicalize -i examples/enrollment.json
```

Sigstore enrollment example with claims (legacy `--identity` and `--issuer` are mapped to claims):

```sh
npx webcat enrollment create \
  --type sigstore \
  --community-trusted-root \
  --identity alice@example.com \
  --issuer https://token.actions.githubusercontent.com \
  --build-signer-uri https://github.com/acme/repo/.github/workflows/release.yml@refs/heads/main \
  --claim 1.3.6.1.4.1.57264.1.11=platform-hosted \
  --max-age 3600
```

## Manifest helpers

The `manifest` namespace operates on WEBCAT manifests:

| Command | Purpose |
| --- | --- |
| `manifest generate` | Scan a directory of static assets, apply a manifest config, and embed a timestamp for `--type sigsum` (Sigsum log); sigstore manifests omit timestamps. |
| `manifest sign` | Sign a manifest with Sigsum (default) or Sigstore and attach proofs/bundles. |
| `manifest canonicalize` | Canonicalize an existing manifest JSON document. |
| `manifest hash` | Canonicalize and SHA-256 hash a manifest, outputting a base64url digest. |
| `manifest verify` | Verify signatures in a manifest (or bundle) against an enrollment and print the policy hash. |

`manifest generate` skips dotfiles and dotfolders by default; pass `--include-dotfiles` to include them. Use
`--exclude <path>` (repeatable) to omit specific files or directories from the scan.

Example – hash the provided manifest:

```sh
npx webcat manifest hash -i examples/manifest.json
# => 8OYr4SFw2U2NR2efE69FAKZicf_2QbUGxXT7kxN1C80
```

Example – verify a bundle:

```sh
npx webcat manifest verify examples/bundle.json
```

### Sigstore signing

Sigstore signing defaults to the community Fulcio/Rekor services. You can override the
endpoints with `--fulcio-url`, `--rekor-url`, and `--tsa-url` when signing.

To sign with Sigstore using an ambient OIDC token (for example, in CI):

```sh
npx webcat manifest sign \
  --type sigstore \
  --input manifest.json
```

If you already have an OIDC ID token, you can pass it explicitly:

```sh
npx webcat manifest sign \
  --type sigstore \
  --input manifest.json \
  --oidc-token "$OIDC_ID_TOKEN"
```

To perform an interactive device authorization flow (opens a browser and prompts for a code):

```sh
npx webcat manifest sign \
  --type sigstore \
  --input manifest.json \
  --interactive
```

To use custom Sigstore infrastructure:

```sh
npx webcat manifest sign \
  --type sigstore \
  --input manifest.json \
  --fulcio-url https://fulcio.example.com \
  --rekor-url https://rekor.example.com \
  --tsa-url https://tsa.example.com \
  --oidc-issuer https://oauth2.example.com/auth \
  --oidc-client-id example-client \
  --interactive
```

## Bundle helpers

Use `bundle create` to combine an enrollment and a manifest (with signatures) into a WEBCAT bundle that can be distributed to verifiers:

```sh
npx webcat bundle create -e examples/enrollment.json -m examples/manifest.json > bundle.json
```

The resulting `bundle.json` matches the fixture located in `examples/bundle.json`.

## End-to-end example (based on `demo.sh`)

The repository includes [`demo.sh`](./demo.sh), which exercises the full workflow. The commands
below mirror that script so you can quickly test the CLI end to end:

```sh
# 1) Prepare demo keys
mkdir -p keys
sigsum-key generate -o keys/key1
sigsum-key generate -o keys/key2
HEX1=$(sigsum-key to-hex -k keys/key1.pub)
HEX2=$(sigsum-key to-hex -k keys/key2.pub)

# 2) Create trust policy and app config
cat > trust_policy <<'EOF'
log 4644af2abd40f4895a003bca350f9d5912ab301a49c77f13e5b6d905c20a5fe6 https://test.sigsum.org/barreleye
witness poc.sigsum.org/nisse 1c25f8a44c635457e2e391d1efbca7d4c2951a0aef06225a881e46b98962ac6c
witness rgdd.se/poc-witness  28c92a5a3a054d317c86fc2eeb6a7ab2054d6217100d0be67ded5b74323c5806
group  demo-quorum-rule any poc.sigsum.org/nisse rgdd.se/poc-witness
quorum demo-quorum-rule
EOF

cat > webcat.config.json <<'EOF'
{
  "app": "https://github.com/element-hq/element-web",
  "version": "1.12.3",
  "default_csp": "default-src 'none'; style-src 'self' 'unsafe-inline'; script-src 'self' 'wasm-unsafe-eval'; img-src * blob: data:; connect-src * blob:; font-src 'self' data: ; media-src * blob: data:; child-src blob: data:; worker-src 'self'; frame-src blob: data:; form-action 'self'; manifest-src 'self'; frame-ancestors 'self'",
  "default_index": "index.html",
  "default_fallback": "/error.html",
  "wasm": ["8A7Ecx-qI7PnFNAOiNTRDi31wKQn06K0rm41Jv3RTvc"],
  "extra_csp": {}
}
EOF

# 3) Produce enrollment and manifest
TMPDIR=$(mktemp -d)
echo index > "$TMPDIR/index.html"
echo error > "$TMPDIR/error.html"

npx webcat enrollment create \
  --policy-file trust_policy \
  --threshold 1 \
  --max-age 15552000 \
  --cas-url https://cas.demoelement.com \
  --signer "$HEX1" \
  --signer "$HEX2" \
  --output enrollment.json

npx webcat manifest generate \
  --policy-file trust_policy \
  --config webcat.config.json \
  --directory "$TMPDIR" \
  --output manifest_unsigned.json

npx webcat manifest sign \
  --policy-file trust_policy \
  -i manifest_unsigned.json \
  -k keys/key1 \
  -o manifest.json

# 4) Bundle and verify
npx webcat bundle create \
  --enrollment enrollment.json \
  --manifest manifest.json \
  --output bundle.json
npx webcat manifest verify bundle.json
```

The script prints intermediate JSON artifacts with `jq` so you can inspect the
resulting enrollment, manifest, and bundle.

## `webcat.config.json` schema

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

Use the JSON example in the workflow above as a starting point and adjust fields
to match your application.

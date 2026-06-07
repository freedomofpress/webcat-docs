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

# Enrollment Commands

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

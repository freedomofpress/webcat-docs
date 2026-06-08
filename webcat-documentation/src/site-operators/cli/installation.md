## Requirements

- Node.js 20 or newer.
- `sigsum-submit` must be available on your `$PATH` for `manifest sign` operations. (See the [installation instructions](#installation) below.)
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

# Installation

## Requirements

- Node.js 20 or newer.
- `sigsum-submit` must be available on your `$PATH` for `manifest sign` operations. (See [Installing the CLI](#installing-the-cli) below.)
- A Sigsum trust policy and keypair for signing manifests.
- An OIDC identity token in the environment (CI-supported) or interactive login for `manifest sign --type sigstore`.

## Installing the CLI

```sh
npm install @freedomofpress/webcat-cli
```

To run the installed CLI:

```sh
npx webcat --help
```

Sigsum needs to be installed separately, as it currently is only available in Go binaries. [Install Go](https://go.dev/doc/install) if needed, then:

```
go install sigsum.org/sigsum-go/cmd/sigsum-key@latest
go install sigsum.org/sigsum-go/cmd/sigsum-submit@latest
```

By default, these binaries will be available in `$HOME/go/bin`. Add this to your system path, then run `sigsum-key` to verify it can be found.

## Using the CLI

Once installed, you can use the CLI and sigsum for [manual signing](../manual.md) of your web assets manifest.

Or, to learn more details on the sub-commands within the CLI, check the [enrollment](./enrollment.md), [mainfest](./manifest.md), and [bundle](./bundle.md) command references.


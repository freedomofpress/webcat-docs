# For Site Operators
If you are developing and hosting your own web application, you should first refer to the [Developer Documentation](../developers/README.md). If you are hosting a third party web application, they should provide their own instructions for deployment.

## Getting Started
As introduced in the [Introduction](../introduction.md), WEBCAT need two main configuration and metadata files for enrolling into the system and provide all the necessary information to browsers for verification. 

## Installing the tools
The [webcat-cli](https://github.com/freedomofpress/webcat-cli) utility requires Node 20+ and npm. It can be installed with:

```bash
npm install @freedomofpress/webcat-cli
```

If you plan to use Sigsum, you also need the Sigsum utilities, which depends are written in go, and should be available in `$PATH` for webcat-cli to use them.

```bash
go install sigsum.org/sigsum-go/cmd/sigsum-key@latest
go install sigsum.org/sigsum-go/cmd/sigsum-submit@latest
```

The webcat-cli is divided in subcommands:
 - `enrollment` is used to generate and manipulate `enrollment.json` information
 - `manifest` is used to generate and sign `manifest.json` files
 - `bundle` is used to bundle together `enrollment.json` and `manifest.json` to provide a single bundle to clients

The Github Actions are available in the [webcat-cli repository](https://github.com/freedomofpress/webcat-cli/tree/main/.github/workflows) and an example of their usage can be seen in the [webcat-demo-test repository](https://github.com/freedomofpress/webcat-demo-test/tree/main/.github/workflows).

### Enrollment
The `/.well-known/webcat/enrollment.json` file contains information about the root of trust and how to verify it. For instance, in the case of a Sigstore-type enrollment, it records the trust material for Sigstore, and claims about provenance or identities. In the case of a Sigsum-type enrollment, it records the public keys of the authorized signers, a minimum threshold of valid signatures, and the Sigsum trust policy.

This information has to be recorded and validated in the [*enrollment system*](../concepts.md). WEBCAT infrastructure will provide a way to validate this information out-of-band, ensuring that even in case of server compromises, the root of trust cannot be tampered with. Once the file is in at the `/.well-known/webcat/enrollment.json` path of the domain to be enrolled, the domain can be submitted to the following web inetrface:

👉 **[Go to the Enrollment Interface](https://enroll.webcat.tech/)**

It is reccomended to generate the `enrollment.json` file using either the _webcat-cli_ or the provided Github Actions, and more detailed instructions follow below.

TODO: debugging/help with enrollment instruction.

### Manifest
A WEBCAT manifest describes a web application by listing its files, cryptographic hashes, CSP policies, and additional metadata useful for auditability. It has to be served at `/.well-known/webcat/enrollment.json`

Manifests are authenticated using either **Sigsum** or **Sigstore** signatures. The metadata required to validate these signatures is what is provided in `enrollment.json`.

#### Generating `enrollment.json`
Changes to enrollment information are:

* Transparently logged
* Auditable
* Subject to a delay (cool-down window)

Keep this in mind: if you make a mistake, you may need to wait before updating the enrollment again.

The first decision you must make is whether to use **Sigsum** or **Sigstore**.

##### Choosing Sigsum

[Sigsum](https://www.sigsum.org/), developed by [Glasklar Teknik](https://www.glasklarteknik.se/), provides:

* Compact Ed25519 signatures
* Easy offline signing
* Threshold signing support

You can choose among multiple transparency logs and witness policies, or even run your own witness if you want to have more control.

Sigsum is generally the better choice if:

* You want offline, manual signing
* You do not want to depend on GitHub or other centralized or complex infrastructure

However, due to current tooling limitations, Sigsum is less convenient for fully automated deployment workflows.

To learn more about Sigsum and how to write a policy, see Sigsum's [_Getting Started_](https://www.sigsum.org/getting-started/) guide.


# For site operators

These are instructions for [site operators](../concepts.md#site-operators) who want to enroll their domain and allow WEBCAT to verify the web assets that they publish.

Assets that WEBCAT can verify include any web apps that meet [the requirements](../webapp-developers/requirements.md). If you are developing and hosting your own web app, you should first refer to our [developer documentation](../webapp-developers/), then return here when it's time to publish. If you are hosting a third-party web app intended to be WEBCAT compliant, the third party should provide instructions; if they don't, reach out to them to see if they are open to WEBCAT compliance. WEBCAT can also verify other static web assets or fully static websites.

> We are working to make this process more clear, accessible and straightforward. We welcome feedback on the [documentation, in its repo](https://github.com/freedomofpress/webcat-docs). If you are a [web app developer](../concepts.md#web-app-developers) or a site operator and have issues following this process, feel free to file an issue in the [extension GitHub repository](https://github.com/freedomofpress/webcat).

## Getting Started
WEBCAT needs two main configuration and metadata files for enrolling into the system and providing all the necessary information to browsers for verification: an `enrollment.json` and a `manifest.json`, which are combined into a `bundle.json`.

These files are produced with the [`webcat-cli`](./cli/) utility. See its [installation instructions](./cli/installation.md) to get set up with the CLI, then follow [manual signing](./manual.md) steps or the [end-to-end example](./cli/end-to-end.md) to get your website on WEBCAT. Or, use the provided [GitHub Actions](./GA.md) which automate this flow for Sigstore-based deployments.

Detailed [enrollment](./cli/enrollment.md), [manifest](./cli/manifest.md), and [bundle](./cli/bundle.md) CLI references are also available.


### Enrollment
The `/.well-known/webcat/enrollment.json` file contains information about the root of trust and how to verify it. For instance, in the case of a Sigstore-type enrollment, it records the trust material for [Sigstore](../concepts.md#sigstore), and claims about provenance or identities. In the case of a Sigsum-type enrollment, it records the public keys of the authorized signers, a minimum threshold of valid signatures, and the [Sigsum](../concepts.md#sigsum) [trust policy](../concepts.md#trust-policy).

This information has to be recorded and validated in the [enrollment infrastructure](../concepts.md#enrollment-infrastructure). The [enrollment infrastructure](../concepts.md#enrollment-infrastructure) provides a way to verify this information out-of-band, ensuring that even in case of server compromises, the root of trust cannot be tampered with. Once the file is at the `/.well-known/webcat/enrollment.json` path of the domain to be enrolled, the domain can be submitted to the following web interface:

👉 **[Go to the Enrollment Interface](https://enroll.webcat.tech/)**

The first decision you must make is whether to use **Sigsum** or **Sigstore** — see [Choosing Sigsum or Sigstore](./cli/sigsum-or-sigstore.md). It is recommended to generate the `enrollment.json` file using either the `webcat-cli` or the provided GitHub Actions.

### Manifest
A WEBCAT [manifest](../concepts.md#manifest) describes a web app by listing its files, cryptographic hashes, CSP policies, and additional metadata useful for auditability. The site serves it only as part of the [bundle](../concepts.md#bundle).

Manifests are authenticated using either **Sigsum** or **Sigstore** signatures. The metadata required to validate these signatures is what is provided in `enrollment.json`.

For step-by-step instructions, follow [Manual Signing](./manual.md) or the [end-to-end example](./cli/end-to-end.md).

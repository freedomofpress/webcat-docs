# For site operators

These are instructions for website publishers or administrators who want to enroll their domain and allow WEBCAT to verify the web assets that they publish.

Assets that WEBCAT can verify include any web apps that meet [the requirements](../webapp-developers/requirements.md). If you are developing and hosting your own web application, you should first refer to our [developer documentation](../webapp-developers/README.md), then return here when it's time to publish. If you are hosting a third-party web application intended to be WEBCAT compliant, the third party should provide instructions; if they don't, reach out to them to see if they are open to WEBCAT compliance. WEBCAT can also verify other static web assets or fully static websites.

> We are working to make this process more clear, accessible and straightforward. We welcome feedback on the [documentation, in its repo](https://github.com/freedomofpress/webcat-docs). If you are a developer or a website administrator and have issues following this process, feel free to file an issue in the [extension Github repository](https://github.com/freedomofpress/webcat).

## Getting Started
WEBCAT needs two main configuration and metadata files for enrolling into the system and providing all the necessary information to browsers for verification: an `enrollment.json` and a `manifest.json`, which are combined into a `bundle.json`.

These files are produced with the [`webcat-cli`](./cli/README.md) utility. See its [installation instructions](./cli/installation.md) to get set up, and the [enrollment](./cli/enrollment.md), [manifest](./cli/manifest.md), and [bundle](./cli/bundle.md) command references for usage. The provided [GitHub Actions](./GA.md) automate this flow for Sigstore-based deployments.

### Enrollment
The `/.well-known/webcat/enrollment.json` file contains information about the root of trust and how to verify it. For instance, in the case of a Sigstore-type enrollment, it records the trust material for Sigstore, and claims about provenance or identities. In the case of a Sigsum-type enrollment, it records the public keys of the authorized signers, a minimum threshold of valid signatures, and the Sigsum trust policy.

This information has to be recorded and validated in the [*enrollment system*](../concepts.md). WEBCAT infrastructure will provide a way to validate this information out-of-band, ensuring that even in case of server compromises, the root of trust cannot be tampered with. Once the file is at the `/.well-known/webcat/enrollment.json` path of the domain to be enrolled, the domain can be submitted to the following web interface:

👉 **[Go to the Enrollment Interface](https://enroll.webcat.tech/)**

The first decision you must make is whether to use **Sigsum** or **Sigstore** — see [Choosing Sigsum or Sigstore](./cli/sigsum-or-sigstore.md). It is recommended to generate the `enrollment.json` file using either the `webcat-cli` or the provided GitHub Actions.

### Manifest
A WEBCAT manifest describes a web application by listing its files, cryptographic hashes, CSP policies, and additional metadata useful for auditability. It has to be served at `/.well-known/webcat/manifest.json`.

Manifests are authenticated using either **Sigsum** or **Sigstore** signatures. The metadata required to validate these signatures is what is provided in `enrollment.json`.

For step-by-step instructions, follow [Manual Signing](./manual.md) or the [end-to-end example](./cli/end-to-end.md).

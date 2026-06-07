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

# WEBCAT CLI

Utilities for creating, validating, and packaging WEBCAT enrollments and manifests.

## Quick Start

This utility, together with the GitHub Actions provided in the same repository, can be used to quickly integrate and enroll a web application or domain into WEBCAT. The recommended steps are:

1. [Prepare your web application](../../webapp-developers/preparing-your-app.md) so it is compatible with WEBCAT.
2. [Choose Sigsum or Sigstore](./sigsum-or-sigstore.md) for enrollment.
3. [Install the CLI](./installation.md).
4. Produce your artifacts with the [enrollment](./enrollment.md), [manifest](./manifest.md), and [bundle](./bundle.md) commands — see the [end-to-end example](./end-to-end.md).
5. Configure your application with [`webcat.config.json`](./config-schema.md).

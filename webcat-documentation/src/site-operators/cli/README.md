# WEBCAT CLI

The CLI contains utilities for creating, validating, and packaging WEBCAT enrollments and manifests. It can be used to quickly integrate and enroll a web application or domain into WEBCAT.

The [CLI code repository](https://github.com/freedomofpress/webcat-cli) also contains [GitHub Actions](../GA.md) which automate the use of the CLI.

## Quick Start

If you are a **website operator** or publisher, here is how you can use the CLI to get your website onto WEBCAT:

1. [Choose Sigsum or Sigstore](./sigsum-or-sigstore.md) for enrollment.
2. [Install the CLI](./installation.md).
3. Produce WEBCAT artifacts by following the [manual signing](../manual.md) steps.
    * (Or, use the [end-to-end example](./end-to-end.md) example of those steps, or the [the GitHub Actions](../GA.md) automation of those steps.)
    * Refer to [`webcat.config.json`](./config-schema.md) when creating your configuration file.

If you are also the **developer** of the web app you will be publishing, you must first [prepare your web application](../../webapp-developers/preparing-your-app.md) so it is compatible with WEBCAT. 


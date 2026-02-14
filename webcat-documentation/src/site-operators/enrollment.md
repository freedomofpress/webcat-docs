# Site Enrollment

## Reproducibility for static sites

If you use WEBCAT's [GitHub Actions workflows](https://github.com/freedomofpress/webcat-cli/blob/main/README.md#choosing-sigstore) to automate updates to a static site's enrollment and manifest, you must integrate them in a way that preserves the site's reproducibility even when these WEBCAT-generated files have changed.  Specifically, merging changes to these files:

- MUST publish the site with these changes included, including rebuilding the site if necessary.
- MUST NOT cause other files (i.e., outside of the `.well-known/webcat`) path to change.  For example, version numbers and timestamps MUST remain unchanged.
- MUST NOT trigger a loop of updates to these files.

One way to meet satisfy these requirements is to separate the workflows:

1. A **build with WEBCAT** workflow runs on changes to files *except* `.well-known/webcat` and runs the WEBCAT-specific workflows.
2. A **publish** workflow runs on changes to *any* files and actually publishes the site, including updates to WEBCAT-generated files merged from (1).

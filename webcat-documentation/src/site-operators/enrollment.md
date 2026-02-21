# Site Enrollment

Site enrollment is the process of:

1. publishing the WEBCAT artifacts that let the browser extension verify your
   site; and

2. keeping those artifacts current as your site evolves.

This page focuses on how to use WEBCAT-provided GitHub Actions workflows to
integrate `webcat-cli` with Sigstore into a static site's CI/CD pipeline without
breaking reproducibility. For prerequisites, such as choosing between Sigstore
and Sigsum, `webcat-cli` usage, and the `webcat.config.json` schema, see the
[`webcat-cli` readme][readme].

[readme]: https://github.com/freedomofpress/webcat-cli/blob/main/README.md

## WEBCAT artifacts

The following files must be served from your site's `/.well-known/webcat/` path:

| File                                         | Description                            |
| -------------------------------------------- | -------------------------------------- |
| `enrollment.json` and `enrollment-prev.json` | The [enrollment information][concepts] |
| `manifest.json`                              | The [manifest][concepts]               |
| `bundle.json` and `bundle-prev.json`         | The [bundle][concepts]                 |

[concepts]: ../concepts/

All of these files are committed to the source repository. They are updated as
part of the WEBCAT-provided GitHub Actions workflows, not regenerated from
scratch on every build.

### Reproducibility for static sites

WEBCAT's GitHub Actions workflows must be integrated in a way that preserves the
site's reproducibility even when these WEBCAT-generated files have changed.
Specifically, merging changes to these files:

- MUST publish the site with these changes included, including rebuilding the
  site if necessary.

- MUST NOT cause other files (i.e., outside of `.well-known/webcat/`) to change.
  Version numbers and timestamps MUST remain unchanged.

- MUST NOT trigger a loop of updates to these files.

Common pitfalls include:

**Version stamps.** If CI stamps a version string (e.g., `YYYY.MM.DD.HH.MM.SS`)
from the current clock, a rebuild triggered by merging an updated manifest will
produce a different version string than the original build. This changes the
manifest and triggers another cycle. One solution is to derive the version from
the timestamp of the Git commit instead.

**File modification times.** Static-site generators that use file modification
times (mtimes) will produce different output if files are checked out with the
current time rather than their committed time. Clamp mtimes to a consistent
timestamp (e.g., per version or per commit) across builds.

### Workflow architecture

One way to satisfy these reproducibility requirements is to separate concerns
across three workflows:

#### 1. Build with WEBCAT

Triggered on push to the main branch, **excluding** the `.well-known/webcat/`
path. Builds the site, deploys it, and then calls WEBCAT's reusable workflows to
update the manifest and the bundle.

The `paths-ignore` exclusion prevents an infinite loop when CI later commits the
updated manifest.

Jobs, in order:

1. **Build and deploy:** Build the site, deploy it to the CDN, and upload the
   built output and `webcat.config.json` as artifacts for the next step.

2. **Generate manifest:** Generate and sign a new `manifest.json` (in a new pull
   request for review).

3. **Assemble bundle:** Combine the manifest and Sigstore bundle into
   `bundle.json` (in a new pull request for review).

#### 2. Publish

Triggered on push to the main branch, **only** for the `.well-known/webcat/`
path. Rebuilds and redeploys the site so that the newly committed manifests are
served from the CDN.

This workflow must not upload artifacts or trigger the WEBCAT
manifest-generation steps.

#### 3. Enrollment sync

Triggered on a daily schedule (and manually via `workflow_dispatch`). Fetches
the latest Sigstore trusted-root from the upstream WEBCAT CLI repository and
opens a pull request if it differs from the current `enrollment.json`.

Merging the resulting pull request triggers the **Publish** workflow, which
redeploys with the updated enrollment files.

## HTTP header alignment

The `Content-Security-Policy` header set by your CDN or HTTP server must exactly
match the `default_csp` (and any `extra_csp` entries) in the WEBCAT
configuration.

## Initial setup

Before manifests can be generated automatically in CI, the following must be in
place:

1. **Grant workflow permissions.** The CI jobs that open pull requests require
   write permissions. In GitHub, this is **Settings** → **Actions** → **General** →
   **Workflow permissions** →
   **Read and write permissions**.

2. **Configure WEBCAT.** Commit a `webcat.config.json` with the `app` URL,
   `default_csp`, and other fields. Push.

3. **Create `enrollment.json`.** Run the enrollment-sync workflow manually (via
   the GitHub Actions `workflow_dispatch` trigger). Review and merge the pull
   request it opens.

4. **Trigger the first build.** Push a content change (outside of
   `.well-known/webcat/`) to start the build-with-WEBCAT workflow. The manifest and
   bundle will follow automatically in new pull requests.

## Worked example

The following sections illustrate the approach outlined above for a static site
built with [ikiwiki] and deployed to static hosting. Here we use [Cloudflare
Pages]; the Cloudflare-side configuration is not covered.

[Cloudflare Pages]: https://pages.cloudflare.com/
[ikiwiki]: https://ikiwiki.info/

### Repository layout

```
.
├── ikiwiki.setup                     # ikiwiki configuration
├── webcat.config.json                # WEBCAT configuration
├── src/                              # ikiwiki source (srcdir)
│   ├── .well-known/webcat/           # WEBCAT artifacts (committed from steps 3 and 4 above)
│   │   ├── enrollment.json
│   │   ├── enrollment-prev.json
│   │   ├── bundle.json
│   │   ├── bundle-prev.json
│   │   └── manifest.json
│   ├── _headers                      # Cloudflare Pages HTTP headers
│   └── …                             # site content
└── .github/workflows/
    ├── ikiwiki-with-manifest.yaml    # See section: "'Build with WEBCAT' Workflow"
    ├── build-and-deploy.yaml         # See section: "Reusable Build-and-Deploy Job"
    ├── deploy.yaml                   # See section: "Publishing Workflow"
    └── sync-sigstore-enrollment.yml  # See section: "Enrollment-sync Workflow"
```

ikiwiki writes the built site to `dist/`. In addition, in `ikiwiki.setup`,
`include: ^\.well-known` overrides ikiwiki's default behavior of skipping
dot-directories, so that `.well-known/` is included in the built
site.

### "Build with WEBCAT" workflow

```yaml
{{#include examples/ikiwiki-cloudflare/ikiwiki-with-manifest.yaml}}
```

### Reusable build-and-deploy job

```yaml
{{#include examples/ikiwiki-cloudflare/build-and-deploy.yaml}}
```

The version is derived from `git log -1 --format=%cd` (the commit timestamp)
rather than `date -u`, so that rebuilding from the same commit always produces
the same version string.

As discussed above, mtime restoration is necessary because the Git working tree
will have all mtimes set to the checkout time. Clamping them to their
last-commit time (via `git-restore-mtime` from [git-tools]) makes the build
reproducible.

[git-tools]: https://github.com/MestreLion/git-tools

### Publishing workflow

```yaml
{{#include examples/ikiwiki-cloudflare/deploy.yaml}}
```

### Enrollment-sync workflow

```yaml
{{#include examples/ikiwiki-cloudflare/sync-sigstore-enrollment.yaml}}
```

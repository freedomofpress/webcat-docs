# For Developers

To operate correctly, a web application MUST satisfy a small set of constraints designed to provide security, consistency, and auditability. These constraints ensure that WEBCAT can reliably reason about what code is executed in the browser and how it evolves over time.
For a more detailed discussion of the design rationale, see [this blog post](https://securedrop.org/news/webcat-towards-auditable-web-application-runtimes/).

## The application MUST be static

All assets that constitute the logic and user interface of the web application MUST be known and fixed at signing time. Server-generated HTML, scripts, or stylesheets are not supported. This includes, for example, mixed PHP/HTML pages, server-side templating systems, and Server-Side Includes (SSI).

WEBCAT can validate the integrity of any asset type, but it enforces integrity *strictly* only for HTML, JavaScript, and CSS. For other asset types, integrity verification depends on whether a corresponding path is explicitly listed in the manifest.

This enables a clear separation between:

* **Application assets**, such as UI images or static translation files, which can be included in the manifest and verified, and
* **Data assets**, such as user-generated or server-generated content (e.g., avatars or API responses), which SHOULD NOT be included.

For example, JSON files containing static application strings (such as translations) may be listed in the manifest, while REST API endpoints returning dynamic application data should not.

## All executable code MUST be known at release time

Any asset subject to integrity verification MUST NOT be able to execute code that was not included at manifest generation and signing time. As a result, dynamic code execution mechanisms, such as `eval()` or instantiating Workers from `blob:` URLs, are disallowed.

WEBCAT enforces this primarily at the Content Security Policy (CSP) level. For example, CSPs that permit `unsafe-eval` or allow script sources that are not enrolled in WEBCAT are rejected.

This constraint introduces some trade-offs. It disallows certain common patterns and makes it difficult to integrate third-party JavaScript that is dynamically served or heavily obfuscated, such as anti-spam or DDoS protection pages, or opaque scripts like Google or Cloudflare CAPTCHA.

While it is theoretically possible to download such scripts and include them as static application assets, doing so is fragile: the upstream code may change at any time, breaking functionality, and it may not be compatible with the CSP restrictions required by WEBCAT. Moreover, including large, opaque, and obfuscated code blobs undermines WEBCAT's auditability and monitoring goals.

## Content Security Policy restrictions



## Site Enrollment

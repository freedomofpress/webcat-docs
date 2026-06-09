# Prepare the web application for compatibility

Before anything else, you should evaluate whether your website or web application is compatible with WEBCAT. There are a few strict requirements:

* The frontend **must be fully static** (i.e., no server-generated HTML, JavaScript, or CSS).
* **No inline JavaScript** is allowed.
* A **Content Security Policy (CSP)** must be provided via an HTTP header and must satisfy specific constraints (see: [CSP Guide](./CSP.md), [explanation blog post](https://securedrop.org/news/webcat-towards-auditable-web-application-runtimes/)).

See the following examples and porting guides (outdated):
 - [Cryptpad](https://github.com/freedomofpress/webcat/tree/main/apps/cryptpad)
 - [Element](https://github.com/freedomofpress/webcat/tree/main/apps/element)
 - [Globaleaks](https://github.com/freedomofpress/webcat/tree/main/apps/globaleaks)
 - [Jitsi](https://github.com/freedomofpress/webcat/tree/main/apps/jitsi)

At the end, you should have compiled a [`webcat.config.json`](../site-operators/cli/config-schema.md) base file for your use case.

# Prepare the web app for compatibility

Before anything else, you should evaluate whether your website or web app is compatible with WEBCAT. There are a few strict requirements:

* The frontend **must be fully static** (i.e., no server-generated HTML, JavaScript, or CSS).
* **No inline JavaScript** is allowed.
* A **Content Security Policy (CSP)** must be provided via an HTTP header and must satisfy specific constraints (see: [CSP Guide](./CSP.md), [explanation blog post](https://securedrop.org/news/webcat-towards-auditable-web-application-runtimes/)).

See the following examples and porting guides (outdated):
 - [Cryptpad](https://github.com/freedomofpress/webcat/tree/main/apps/cryptpad)
 - [Element](https://github.com/freedomofpress/webcat/tree/main/apps/element)
 - [Globaleaks](https://github.com/freedomofpress/webcat/tree/main/apps/globaleaks)
 - [Jitsi](https://github.com/freedomofpress/webcat/tree/main/apps/jitsi)

## Detecting WEBCAT at runtime

On an enrolled origin, the extension defines `window.hasWebcat` as `true` on every page and frame before any page script runs. The property is read-only, and it does not exist when the extension is not installed or the origin is not enrolled. A web app can use it to adapt its UI, for example to tell users on Firefox to install the WEBCAT browser extension to get additional verification.

```js
if (window.hasWebcat !== true) {
  // suggest installing the extension
}
```

Do not use it for security decisions: any page, and any other extension can define the same property on itself.

At the end, you should have compiled a [`webcat.config.json`](../site-operators/cli/config-schema.md) base file for your use case.

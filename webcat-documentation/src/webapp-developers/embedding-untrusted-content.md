# Embedding untrusted content

Some components cannot be enrolled in WEBCAT: CAPTCHAs, 3-D Secure challenges, payment forms, embedded players, and any code that a third party serves dynamically. The same applies to content the application itself produces from untrusted input, such as a Markdown preview, an HTML email, or a user-uploaded document. None of this can be included in the signed manifest, and none of it should run in the verified document.

The supported pattern is to isolate such content in an `<iframe>`, restrict the frame with the `sandbox` attribute, and exchange data with it exclusively through `postMessage`. The `frame-src` and `child-src` directives are not restricted by WEBCAT (see [CSP](./CSP.md#frame-src-child-src)), so a verified page may embed frames freely. What runs inside the frame is not verified, and the browser keeps it isolated from the verified document.

Two properties make this safe:

 - **Origin isolation.** WEBCAT adds `Origin-Agent-Cluster: ?1` to every enrolled document. A frame on a different origin cannot reach the embedding document's DOM, storage or cookies, and cannot relax this with `document.domain`.
 - **Sandboxing.** The `sandbox` attribute removes capabilities from the frame regardless of its origin. A sandboxed frame without `allow-same-origin` gets an opaque origin, so even content served from the application's own origin cannot access the application's state.

Never combine `allow-scripts` and `allow-same-origin` on a frame whose content is same-origin with the application. This includes `srcdoc` frames, which take the embedding document's origin when `allow-same-origin` is set. Such a frame is same-origin with the verified document and can script it directly through `window.parent`, so the sandbox provides no isolation.

## Message passing

Communication between the verified document and a frame goes through `postMessage`. On the receiving side, always check both the sender and the shape of the message:

 - `event.origin` must equal the expected origin of the frame. For a sandboxed frame without `allow-same-origin` this value is the string `"null"`.
 - `event.source` must be the frame's `contentWindow`, so that another frame or window on the same origin cannot inject messages.
 - `event.data` must have the expected type and fields. Treat it as untrusted input.

When sending, pass the exact target origin as the second argument rather than `"*"`, so that a navigated or hijacked frame does not receive the message. Sending to a frame with an opaque origin requires `"*"`; in that case the message must not contain anything sensitive.

Anything the frame returns, such as a CAPTCHA token or a payment authorisation, is only a hint for the user interface. The application server must verify it with the provider before acting on it.

Inline scripts in the verified page are allowed only with a hash source in `script-src`. The examples below use an external file listed in the manifest, which avoids updating the hash whenever the script changes.

## Example: third-party widget

A CAPTCHA, a 3-D Secure challenge or a hosted payment form is served by a provider. If the provider offers a hosted page that can be framed directly, use it. If the provider only offers a script to include in the page, host a small relay page on a separate origin that is not enrolled, for example `widgets.example.net`, and frame that. The relay page loads the provider script and forwards the result to the application.

The `frame-src` directive falls back to `default-src`. With the example policy from the [CSP page](./CSP.md#writing-a-policy), `default-src 'none'` blocks all frames, so add `frame-src https://widgets.example.net` to the policy.

Verified document (`index.html`):

```html
<iframe id="captcha"
        src="https://widgets.example.net/captcha.html"
        sandbox="allow-scripts allow-forms allow-same-origin"
        referrerpolicy="no-referrer"></iframe>
<input type="hidden" id="captcha-token" name="captcha_token">
<script src="/js/captcha.js"></script>
```

Verified document (`/js/captcha.js`, listed in the manifest):

```js
const WIDGET_ORIGIN = "https://widgets.example.net";
const frame = document.getElementById("captcha");

window.addEventListener("message", (event) => {
  if (event.origin !== WIDGET_ORIGIN) return;
  if (event.source !== frame.contentWindow) return;
  const data = event.data;
  if (typeof data !== "object" || data === null) return;

  if (data.type === "captcha-solved" && typeof data.token === "string") {
    document.getElementById("captcha-token").value = data.token;
  }
});

// Optional: configure the widget after it has loaded.
frame.addEventListener("load", () => {
  frame.contentWindow.postMessage({ type: "configure", theme: "dark" }, WIDGET_ORIGIN);
});
```

Relay page on the widget origin (`https://widgets.example.net/captcha.html`, not enrolled):

```html
<!doctype html>
<meta charset="utf-8">
<script src="https://provider.example/api.js" async defer></script>
<div class="provider-widget" data-callback="onSolved"></div>
<script>
  const APP_ORIGIN = "https://app.example.com";

  function onSolved(token) {
    parent.postMessage({ type: "captcha-solved", token: token }, APP_ORIGIN);
  }

  window.addEventListener("message", (event) => {
    if (event.origin !== APP_ORIGIN) return;
    if (event.data && event.data.type === "configure") {
      document.body.dataset.theme = event.data.theme;
    }
  });
</script>
```

Sandbox flags for this case:

 - `allow-scripts` is required for any provider script.
 - `allow-forms` is required if the flow submits a form, as 3-D Secure challenges do.
 - `allow-popups` only if the provider opens a window, for example for a bank login.
 - `allow-same-origin` is required for a cross-origin relay page. Without it the frame has an opaque origin: `event.origin` is `"null"`, messages targeted at the relay origin are dropped, and provider scripts that need cookies, storage or a hostname check against their site key fail. Because the frame is cross-origin, this flag grants access to the relay origin only, never to the application.
 - Powerful features such as camera, microphone, geolocation and payment are not delegated to cross-origin frames unless listed in the `allow` attribute. Grant only what the widget needs, for example `allow="payment"`.

The relay origin is outside WEBCAT's guarantees by design. Keep it minimal, serve it with its own strict CSP, and do not host anything else there.

## Example: rendering sandbox

A preview of user-supplied HTML or Markdown, a rendered email, or a user-uploaded SVG must not be inserted into the verified document with `innerHTML`, and must not be served as a file from the enrolled origin, where WEBCAT would reject it as an unsigned HTML asset. Render it in a fully sandboxed frame instead.

```html
<iframe id="preview" sandbox="" referrerpolicy="no-referrer"></iframe>
<script src="/js/preview.js"></script>
```

```js
const preview = document.getElementById("preview");

function showPreview(untrustedHtml) {
  preview.srcdoc = untrustedHtml;
}
```

An empty `sandbox` attribute disables scripts, forms, popups, top-level navigation and gives the frame an opaque origin. The rendered content can display text, images and styles and nothing else. A `srcdoc` frame inherits the CSP of the embedding document, so the same `img-src` and `style-src` rules that apply to the application also apply to the preview. It is not a network request and is not matched against `frame-src`, so no change to the policy is needed to embed it, even under `default-src 'none'`.

If the preview must execute scripts, for example a code playground, do not enable them in a `srcdoc` frame. Serve the renderer from a separate origin that is not enrolled and follow the third-party widget pattern above.

## Checklist

 - Untrusted content lives in an `<iframe>`, never in the verified document.
 - Every frame has a `sandbox` attribute with the smallest set of flags that works.
 - No frame has both `allow-scripts` and `allow-same-origin` unless its content is cross-origin.
 - Message handlers check `event.origin`, `event.source` and the message shape.
 - `postMessage` is called with an explicit target origin.
 - Tokens and results from a frame are verified server-side before use.

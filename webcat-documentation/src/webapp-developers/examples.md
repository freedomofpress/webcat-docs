# Examples
We have tentatively ported a few selected open-source web apps to prove their potential compatibility with WEBCAT. No official support is provided. As such, [site operators](../concepts.md#site-operators) are discouraged from deploying these apps without prior testing and understanding that updates might break compatibility or require significant additional work.

### Test app

> If you are porting your own application, start with [Prepare the web app for compatibility](./preparing-your-app.md).

### Test App
 - [URL](https://test.demo.webcat.tech/)
 - [Source Code](https://github.com/freedomofpress/webcat-demo-test)
 - [webcat.config.json](https://github.com/freedomofpress/webcat-demo-test/blob/main/webcat.config.json)
 - [enrollment.json](https://test.demo.webcat.tech/.well-known/webcat/enrollment.json)

The demo app showcases a simple static page using WebAssembly and different types of workers. The page verifies all its assets, including fonts.

### Element
 - [URL](https://element.demo.webcat.tech/)
 - [Source Code](https://github.com/freedomofpress/webcat-demo-element)
 - [webcat.config.json](https://github.com/freedomofpress/webcat-demo-element/blob/main/webcat.config.json)
 - [enrollment.json](https://element.demo.webcat.tech/.well-known/webcat/enrollment.json)

[Element](https://element.io/) is the well-known web-based Matrix client. It is natively compatible with WEBCAT, requiring no modification to its source code or build process. Once built, it can be signed directly using [webcat-cli](../concepts.md#webcat-cli) and the sample `webcat.config.json` config file.

### Tinfoil Verification Center
 - [URL](https://verification-center.tinfoil.sh/)
 - [Source Code](https://github.com/tinfoilsh/verification-center)
 - [webcat.config.json](https://github.com/tinfoilsh/verification-center/blob/main/webcat/webcat.config.json)
 - [enrollment.json](https://verification-center.tinfoil.sh/.well-known/webcat/enrollment.json)
 - [Publishing/Signing Workflow](https://github.com/tinfoilsh/verification-center/blob/main/.github/workflows/vercel.yaml)

The [Tinfoil.sh](https://tinfoil.sh) Verification Center is an embeddable iframe with the goal of verifying confidential computing attestations and attributes for the Tinfoil stack. It is a [Next.js](https://nextjs.org/) static web app hosted directly on Vercel. The workflow describes the steps required to deploy WEBCAT in this setup. The Verification Center is currently loaded as an iframe in production at [chat.tinfoil.sh](https://chat.tinfoil.sh).

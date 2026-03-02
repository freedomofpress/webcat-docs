# Examples
We have tentatively ported a few selected open-source web application to prove their potential compatibility with WEBCAT. No official support is provided, as such, administrators as discouraged from deploying them without prior testing, and understanding that updates might be breaking, or require significant additional work.

### Test App
 - [URL](https://app.demo.webcat.tech/)
 - [Source Code](https://github.com/freedomofpress/webcat-demo-test)
 - [webcat.config.json](https://app.demo.webcat.tech/.well-known/enrollment.json)
 - [enrollment.json](https://app.demo.webcat.tech/.well-known/enrollment.json)

The demo app showcases a simple static page, using WebAssembly, and different type of workers. The page verifies all its assets, including fonts.

### Element
 - [URL](https://element.demo.webcat.tech/)
 - [Source Code](https://github.com/freedomofpress/webcat-demo-element)
 - [webcat.config.json](https://element.demo.webcat.tech/.well-known/enrollment.json)
 - [enrollment.json](https://element.demo.webcat.tech/.well-known/enrollment.json)

Element is the well-known web-based Matrix client. It is natively compatible with WEBCAT, requiring no modification to its source code or build process. Once built, it can be signed directly using WEBCAT CLI and the sample `webcat.config.json` config file.
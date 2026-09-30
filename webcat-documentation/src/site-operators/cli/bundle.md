# Bundle Commands

Use `bundle create` to combine an enrollment and a [manifest](../../concepts.md#manifest) (with signatures) into a WEBCAT [bundle](../../concepts.md#bundle) that can be distributed to verifiers:

```sh
npx webcat bundle create -e examples/enrollment.json -m examples/manifest.json > bundle.json
```

The resulting `bundle.json` matches the fixture located in [`examples/bundle.json`](https://github.com/freedomofpress/webcat-cli/blob/main/examples/bundle.json).

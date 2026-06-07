## Bundle helpers

Use `bundle create` to combine an enrollment and a manifest (with signatures) into a WEBCAT bundle that can be distributed to verifiers:

```sh
npx webcat bundle create -e examples/enrollment.json -m examples/manifest.json > bundle.json
```

The resulting `bundle.json` matches the fixture located in `examples/bundle.json`.

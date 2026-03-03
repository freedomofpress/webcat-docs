# Manual Signing
The following procedure describes how to use the WEBCAT CLI to generate enrollment and metadata information for WEBCAT.

### Create Sigsum Keys

Create a folder where to store the keys. They should be kept secure and stored offline, as they will be used only to sign web application manifests at release time.
```
mkdir -p keys
sigsum-key generate -o keys/key1
sigsum-key generate -o keys/key2
```

Let's save the public keys in a variable, as they will be useful in the next steps.
```
HEX1=$(sigsum-key to-hex -k keys/key1.pub)
HEX2=$(sigsum-key to-hex -k keys/key2.pub)
```

### Create a Sigsum trust policy
A Sigsum trust policy specifies the transparency log to log to and verify against, as well as a witness policy to independently verify the log's honesty. The following policy is intended for testing, as it uses a testing Sigsum log.

```
cat > trust_policy <<EOF
log 4644af2abd40f4895a003bca350f9d5912ab301a49c77f13e5b6d905c20a5fe6 https://test.sigsum.org/barreleye

witness poc.sigsum.org/nisse 1c25f8a44c635457e2e391d1efbca7d4c2951a0aef06225a881e46b98962ac6c
witness rgdd.se/poc-witness  28c92a5a3a054d317c86fc2eeb6a7ab2054d6217100d0be67ded5b74323c5806

group  demo-quorum-rule any poc.sigsum.org/nisse rgdd.se/poc-witness
quorum demo-quorum-rule
EOF
```

### Create a WEBCAT config file
Write a `webcat.config.json` file. All the fields in the example are mandatory as keys, though their values can be empty. For instance, `wasm` has to be an array, but can be empty. Choose a content security policy according to the [CSP guide](../developers/CSP.md).

cat > webcat.config.json <<EOF
{
  "app": "https://github.com/element-hq/element-web",
  "version": "1.12.3",
  "default_csp": "default-src 'none'; style-src 'self' 'unsafe-inline'; script-src 'self' 'wasm-unsafe-eval'; img-src * blob: data:; connect-src * blob:; font-src 'self' data: ; media-src * blob: data:; child-src blob: data:; worker-src 'self'; frame-src blob: data:; form-action 'self'; manifest-src 'self'; frame-ancestors 'self'",
  "default_index": "index.html",
  "default_fallback": "/error.html",
  "wasm": [
    "8A7Ecx-qI7PnFNAOiNTRDi31wKQn06K0rm41Jv3RTvc"
  ],
  "extra_csp": {}
}
EOF

### Create enrollment.json

Automatically generate the enrollment file. The CAS storage server should store immutable copies of the generated file using Content Addressable Storage, useful for auditing. Auditing and proper support for it is a work in progress, so it's not strictly necessary now. We also use the `$HEX1` and `$HEX2` variables prepared before during the key generation phase. A `--threshold` of `1` means that only a signature from one of the two keys is required.


```
npx webcat enrollment create --policy-file trust_policy --threshold 1 --max-age 15552000 --cas-url https://cas.demoelement.com --signer "$HEX1" --signer "$HEX2" --output enrollment.json
```

### Generate the unsigned manifest
Generate a manifest file to sign later. Requires in input a `--directory`, which is the path of the assets of the web application to sign. Remember, everything in the folder will be added to the manifest and integrity checked!

The utility supports optional multiple `--exclude` parameters to exclude files from the manifest but that are in the folder. The utility will automatically scan for `.wasm` files to hash and add to the `wasm` array. If you have inline WASM, not sourced from a file, or your WASM files have a different extension, you have to manually add the hashes to the `wasm` array in `webcat.config.json` in base64url format.

```
npx webcat manifest generate --policy-file trust_policy --config webcat.config.json --directory "/path/to/my/app"--output manifest_unsigned.json
```


### Sign the manifest
Use the CLI and one of the keys generated at the beginning to sign the manifest, submit it to the Sigsum log, and collect the proof. In this case, the CLI will invoke one or more of the `sigsum-go` utilities under the hood.

```
npx webcat manifest sign --policy-file trust_policy -i manifest_unsigned.json -k keys/key1 -o manifest.json
```

### Create bundle
Use the CLI to join `enrollment.json` and `manifest.json` into a single `bundle.json` that will then be consumed by the WEBCAT extension in users' browser.

```
npx webcat bundle create --enrollment enrollment.json --manifest manifest.json --output bundle.json
```

### Deploy
Remember to deploy:

 - `/.well-known/webcat/enrollment.json`
 - `/.well-known/webcat/manifest.json`
 - `/.well-known/webcat/bundle.json`


### Check that the bundle verifies
Check that the manifest in a bundle is valid according to its enrollment information.

```
npx webcat manifest verify bundle.json
```

### Submit for enrollment
If everything verifies, you are ready for deployment! Enroll in the WEBCAT enrollment system at [enroll.webcat.tech](https://enroll.webcat.tech)
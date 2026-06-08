# End-to-End Example

This example walks through the full **Sigsum** signing workflow with the CLI. If you are using **Sigstore** instead, you generally do not run these steps manually — see [GitHub Actions](../GA.md).

The webcat-cli repository includes [`demo.sh`](https://github.com/freedomofpress/webcat-cli/blob/main/demo.sh), which exercises the full workflow. The commands
below mirror that script so you can quickly test the CLI end to end:

```sh
# 1) Prepare demo keys
mkdir -p keys
sigsum-key generate -o keys/key1
sigsum-key generate -o keys/key2
HEX1=$(sigsum-key to-hex -k keys/key1.pub)
HEX2=$(sigsum-key to-hex -k keys/key2.pub)

# 2) Create trust policy and app config
cat > trust_policy <<'EOF'
log 4644af2abd40f4895a003bca350f9d5912ab301a49c77f13e5b6d905c20a5fe6 https://test.sigsum.org/barreleye
witness poc.sigsum.org/nisse 1c25f8a44c635457e2e391d1efbca7d4c2951a0aef06225a881e46b98962ac6c
witness rgdd.se/poc-witness  28c92a5a3a054d317c86fc2eeb6a7ab2054d6217100d0be67ded5b74323c5806
group  demo-quorum-rule any poc.sigsum.org/nisse rgdd.se/poc-witness
quorum demo-quorum-rule
EOF

cat > webcat.config.json <<'EOF'
{
  "app": "https://github.com/element-hq/element-web",
  "version": "1.12.3",
  "default_csp": "default-src 'none'; style-src 'self' 'unsafe-inline'; script-src 'self' 'wasm-unsafe-eval'; img-src * blob: data:; connect-src * blob:; font-src 'self' data: ; media-src * blob: data:; child-src blob: data:; worker-src 'self'; frame-src blob: data:; form-action 'self'; manifest-src 'self'; frame-ancestors 'self'",
  "default_index": "index.html",
  "default_fallback": "/error.html",
  "wasm": ["8A7Ecx-qI7PnFNAOiNTRDi31wKQn06K0rm41Jv3RTvc"],
  "extra_csp": {}
}
EOF

# 3) Produce enrollment and manifest
TMPDIR=$(mktemp -d)
echo index > "$TMPDIR/index.html"
echo error > "$TMPDIR/error.html"

npx webcat enrollment create \
  --policy-file trust_policy \
  --threshold 1 \
  --max-age 15552000 \
  --cas-url https://cas.demoelement.com \
  --signer "$HEX1" \
  --signer "$HEX2" \
  --output enrollment.json

npx webcat manifest generate \
  --policy-file trust_policy \
  --config webcat.config.json \
  --directory "$TMPDIR" \
  --output manifest_unsigned.json

npx webcat manifest sign \
  --policy-file trust_policy \
  -i manifest_unsigned.json \
  -k keys/key1 \
  -o manifest.json

# 4) Bundle and verify
npx webcat bundle create \
  --enrollment enrollment.json \
  --manifest manifest.json \
  --output bundle.json
npx webcat manifest verify bundle.json
```

The script prints intermediate JSON artifacts with `jq` so you can inspect the
resulting enrollment, manifest, and bundle.

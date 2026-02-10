# Run Oracle as HTTP Server

Instead of using the CLI, you can run the oracle as an HTTP server that accepts observation requests via API:

```bash
cargo run --bin felidae oracle server \
  --homedir /persistent/keys \
  --node http://localhost:26657 \
  --bind 127.0.0.1:8081
```

The server exposes three endpoints:

- `GET /pow-challenge?domain=<domain>` - Request a Proof of Work (PoW) challenge for a domain. Returns JSON: `{"challenge": "<hex>", "timestamp": <unix_secs>, "difficulty": <bits>}`. The client must find a `nonce` such that `SHA256(challenge + nonce)` has at least `difficulty` leading zero bits, then submit that in the observe request.
- `POST /observe` - Submit an observation request. Requires a valid PoW token (see below). JSON body: `{"domain": "example.com.", "pow_token": {"challenge": "<from /pow-challenge>", "nonce": <u64>, "timestamp": <from /pow-challenge>}}`.
- `GET /health` - Health check endpoint.

**Client-side PoW flow:**
1. `GET /pow-challenge?domain=example.com.` to receive `challenge`, `timestamp`, `difficulty`.
2. Find a `nonce` (e.g. by incrementing from 0) such that the SHA256 hash of `challenge + nonce` has at least `difficulty` leading zero bits.
3. `POST /observe` with `{"domain": "example.com.", "pow_token": {"challenge": "...", "nonce": <found>, "timestamp": <same>}}`.

Tokens are valid for 5 minutes. PoW difficulty can be tuned with the `POW_DIFFICULTY` environment variable (default 19, minimum 8).

Example (after computing a valid nonce for the challenge):

```bash
curl -X POST http://localhost:8081/observe \
  -H "Content-Type: application/json" \
  -d '{"domain": "example.com.", "pow_token": {"challenge": "<from /pow-challenge>", "nonce": 12345, "timestamp": 1700000000}}'
```
# Enrollment Infrastructure

See the basic architecture explained [here](../architecture/enrollment-infrastructure.md).

## Getting Started

You'll need to install the following tools:

- Rust
- Go
- protoc
- just

Or you can use the in-repo nix flake to bootstrap tooling.

Once you have the dependencies installed, you can use the justfile targets locally. Build and run the chain by running both CometBFT and Felidae (the ABCI application), each in its own terminal window. Start CometBFT via:

```
just cometbft
```

And the ABCI application via:

```
just felidae
```

Finally, to reset the chain state by blowing away both CometBFT and Felidae's state:

```
just reset
```

Note that the application's genesis file, which contains the initial configuration of the starting state of the chain, is located in ~/.cometbft/config/genesis.json.

*Tip: For more verbose logging, run commands with RUST_LOG=info (or RUST_LOG=debug for even more detail).*

## Testing

Run the standard unit test suite:

```
just test
```

Run the integration tests (spawns a 3-validator network per test):

```
just integration
```

### Block time configuration

Integration tests derive all timing from a configurable block interval (FELIDAE_BLOCK_TIME_SECS, default 1). The default keeps CI fast (~2 min). To test with longer block times (e.g. matching production's 60s):

```
just integration 60
```

Or equivalently:

```
FELIDAE_BLOCK_TIME_SECS=60 just integration
```

## Setting Up Admin and Oracle

### 1. Generate Configuration Template

```
cargo run --bin felidae admin template > config.json
```

This generates a configuration template (see the Config proto) that you'll edit to add your own keys as an admin and oracle.

### 2. Generate Your Admin and Oracle Keypairs

```
cargo run --bin felidae admin init
```

This creates your admin keypair. To view your admin public key:

```
cargo run --bin felidae admin identity
```

Similarly for oracle:

```
cargo run --bin felidae oracle init
```

To view your oracle public key:

```
cargo run --bin felidae oracle identity
```

### 3. Configure config.json

Add your public keys (from step 2) to the authorized lists for both admins and oracles in config.json. For oracles, you'll need to provide both the identity (public key) and endpoint (domain or IP address) for each oracle.

For a single-validator testing setup, configure the following:

Example chain configuration:

```json
{
  "version": 1,
  "admins": {
    "voting": {
      "total": 1,
      "quorum": 1,
      "timeout": "1day",
      "delay": "0s"
    },
    "authorized": ["YOUR_ADMIN_KEY_HERE"]
  },
  "oracles": {
    "enabled": true,
    "voting": {
      "total": 1,
      "quorum": 1,
      "timeout": "5m",
      "delay": "30s"
    },
    "max_enrolled_subdomains": 5,
    "observation_timeout": "5m",
    "authorized": [
      {
        "identity": "YOUR_ORACLE_KEY_HERE",
        "endpoint": "127.0.0.1"
      }
    ]
  },
  "onion": {
    "enabled": false
  }
}
```

*Note: Each oracle in the authorized array must have:*

- *identity: The hex-encoded public key of the oracle (required)*
- *endpoint: The endpoint (domain name or IP address) for the oracle (optional, defaults to "127.0.0.1" if omitted)*

The endpoint is used by frontends to know where to submit enrollment requests to the oracle set.

*Important: You must increment the version number in the config file unless you add the config to the genesis file.*

*Note: You can now skip steps 3-4 by adding the initial chain config in the genesis file by adding an app_state key with the config, e.g.:*

```json
{
  "genesis_time": "2025-09-13T23:47:47.144389Z",
  "chain_id": "my-webcat-testchain",
  "initial_height": 0,
  "app_state": {
    "config": {
      "version": 0,
      "admins": {
        "authorized": [...],
        "voting": { ... }
      },
      "oracles": {
        "enabled": true,
        "authorized": [...],
        "voting": { ... },
        "max_enrolled_subdomains": 5,
        "observation_timeout": "5m"
      },
      "onion": {
        "enabled": false
      }
    }
  }
}
```

### 4. Submit Configuration to Chain

```
cargo run --bin felidae admin config config.json --chain <CHAIN_ID>
```

Replace <CHAIN_ID> with the chain ID from ~/.cometbft/config/genesis.json.

Once the chain accepts this transaction, you'll be configured as both admin and oracle. Verify the current configuration:

```
curl http://localhost:8080/config
```

### 5. Post an Oracle Observation

You can now submit oracle observations. For example:

```
cargo run --bin felidae oracle observe --domain element.nym.re. --zone nym.re.
```

If you omit the --zone, the oracle will automatically infer the zone from the domain using the Mozilla Public Suffix List (PSL).

After the observation reaches quorum and the delay period expires, the observed hash will be visible in the snapshot:

```
curl http://localhost/snapshot
```

## Run Oracle as HTTP Server

Instead of using the CLI, you can run the oracle as an HTTP server that accepts observation requests via API:

```
cargo run --bin felidae oracle server \
  --homedir /persistent/keys \
  --node http://localhost:26657 \
  --bind 127.0.0.1:8081
```

TK: A client side PoW was added that is not documented here.

The server exposes two endpoints:

- POST /observe - Submit observation requests (JSON: {"domain": "example.com.", "zone": "com."})
- GET /health - Health check endpoint

Example request:

```
curl -X POST http://localhost:8081/observe \
  -H "Content-Type: application/json" \
  -d '{"domain": "example.com.", "zone": "com."}'
```

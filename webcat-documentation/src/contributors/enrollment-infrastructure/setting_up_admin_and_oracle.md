# Setting Up Admin and Oracle

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
        "endpoint": "http://127.0.0.1:80"
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

Replace `<CHAIN_ID>` with the chain ID from `~/.cometbft/config/genesis.json`.

Once the chain accepts this transaction, you'll be configured as both admin and oracle. Verify the current configuration:

```
curl http://localhost:8080/config
```

### 5. Post an Oracle Observation

You can now submit oracle observations. For example:

```
cargo run --bin felidae oracle observe --domain element.nym.re. --zone nym.re.
```

If you omit the --zone, the oracle will automatically infer the zone from the domain using the [Mozilla Public Suffix List (PSL)](https://publicsuffix.org/).

After the observation reaches quorum and the delay period expires, the observed hash will be visible in the snapshot:

```
curl http://localhost/snapshot
```


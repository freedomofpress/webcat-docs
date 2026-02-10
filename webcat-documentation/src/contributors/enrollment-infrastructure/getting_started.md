# Getting Started

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

Note that the application's genesis file, which contains the initial configuration of the starting state of the chain, is located in `~/.cometbft/config/genesis.json`.

*Tip: For more verbose logging, run commands with RUST_LOG=info (or RUST_LOG=debug for even more detail).*

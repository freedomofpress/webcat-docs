# Enrollment Preload List

At every finalized block, the current state of the preload list - agreed upon by
2/3 of validators - can be extracted and signed. Any node can then publish this
list for the WEBCAT extension to consume.

The WEBCAT extension does not trust a specific validator. Instead, it verifies that:

- There was valid consensus.
- The current block height/timestamp is greater than the previous one.

The latest `LightBlock` is posted daily:

```
https://webcat.freedom.press/block.json
```

This `LightBlock` contains a signed `AppHash` by the validator set. Clients
verify the state is signed by at least 2/3 of the validator set prior to usage.

The latest snapshot of the canonical state is posted daily to:

```
https://webcat.freedom.press/list.json
```

The snapshot of the canonical state contains:

- Leaves that should be reconstructed client-side to get the root of the canonical state tree
- A Merkle proof of inclusion up to the `AppHash` included in the block

Clients use this data to do full Merkle verification of the canonical
state prior to usage.

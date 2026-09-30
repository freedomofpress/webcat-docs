# Transparency

The blockchain itself serves as a [transparency log](../../concepts.md#transparency-log) of enrollment changes. Note that transparency logging is still required for [manifest](../../concepts.md#manifest) signatures and for [Sigstore](../../concepts.md#sigstore)'s OIDC certificates.

Monitoring can be performed by any blockchain node that is not a [validator](../../concepts.md#validator). Non-validators can perform the same checks on the enrollment [preload list](../../concepts.md#preload-list) state and verify domain consensus, enabling both:

- Monitoring: e.g., a service that alerts [site operators](../../concepts.md#site-operators) when changes are initiated.
- Auditing: independent verification of consensus and list state.

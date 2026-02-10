# Transparency

The blockchain itself serves as a transparency log of enrollment changes. Note that transparency logging is still required for manifest signatures and for Sigstore's OIDC certificates.

Monitoring can be performed by any blockchain node that is not a validator. Non-validators can perform the same checks on the enrollment preload list state and verify domain consensus, enabling both:

- Monitoring: e.g., a service that alerts domain owners when changes are initiated.
- Auditing: independent verification of consensus and list state.

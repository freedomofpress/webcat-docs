# Frequently Asked Questions

## General

### How does WEBCAT work?

### How is this different from HTTPS?

HTTPS doesn't protect your users if the site hosting the web application itself
gets hacked.

### How is this different from Certificate Transparency?

### How is this different from Subresource Integrity (SRI)?

### How is this different from Content Security Policy (CSP)?

### What happens if a site gets compromised after enrollment?

If the resources

### How do users verify that a site is enrolled in WEBCAT?

Users can check if a site is designed to work with WEBCAT via:

`https://<domain>/.well-known/webcat/enrollment.json`

Users can check if a site has been enrolled using the list provided at:

`https://webcat.freedom.press/list.json`

### Does WEBCAT require browser extensions or special software?

Yes, currently users must use the WEBCAT Browser Extension, available in the
Mozilla Add-Ons store.

### What browsers are supported?

Currently, just Mozilla Firefox. We're exploring integration into Tor Browser,
and other browser support. One limitiation is that the current
WEBCAT architecture requires the Manifest V2 API, which was deprecated by
Chromium-based browsers.

### How does WEBCAT affect page load performance?

TODO provide some numbers here

## For Site Owners

### How do I enroll my site in WEBCAT?

You can use the enrollment frontend.

### Is there a cost to enroll my site?

It's free.

### Can I unenroll my site?

Yes, you can unenroll your site by removing your enrollment bundle from:

`https://<domain>/.well-known/webcat/enrollment.json`

and resubmitting your site.

### What happens if I need to update my site's enrollment information?

Simply update your enrollment bundle, and resubmit your site.

Note that changes take 1 day to be updated.

### Does WEBCAT work with subdomains?

Yes, but to limit spam, we allow only 5 subdomains per site.

### How long does enrollment take?

On the alpha testnet, enrollment takes 1 day to take effect.

## Security & Privacy

### Does WEBCAT collect user data?

We only store submitted domains.

### What if the enrollment infrastructure itself is compromised?

If the enrollment infrastructure itself were compromised, an attacker could
unenroll your site from WEBCAT, enabling them to serve malicious code to your
users.

## Enrollment Infrastructure

### Your enrollment infrastructure uses a blockchain. Aren't they bad for the environment / slow / scammy?

Blockchain technology has unfortunately been associated with scams and speculation, but WEBCAT uses blockchain for a specific technical purpose: providing a decentralized, tamper-resistant registry of site enrollments. There is no financial aspect to this blockchain, we're using it as a permissioned distributed database that no single party controls.

The blockchain serves as a public ledger where site enrollment records are stored immutably. This ensures that once a site is enrolled in WEBCAT, that enrollment cannot be retroactively modified or deleted by the chain operator, providing the trust guarantees that WEBCAT requires.

For the design of WEBCAT, we wanted to design an infrastructure that has no single point of failure or control, thus ensuring that no single party can prevent enrollments.

We've chosen a consensus solution (CometBFT) that minimizes environmental impact and cost. The enrollment infrastructure operates at a much lower transaction volume than typical financial blockchains, and we're committed to using energy-efficient consensus mechanisms.

### Why didn't you use my favorite blockchain?

The financial aspect of existing blockchains represents an issue for us. Asking
users to submit a transaction on a traditional blockchain would mean they need
to acquire the native token to pay fees on that chain. That may represent a
challenging UX burden or be impossible for users who want to maintain their
privacy and anonymity. This latter concern is critical for us since we are
planning to enable Tor onion service operators to enroll their sites.

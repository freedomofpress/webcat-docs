# Concepts

## Glossary

### WEBCAT

#### Enrollment information

Enrollment information is a JSON document, defined by the WEBCAT specification, that states the signing identities and *trust policy* for a domain. The *site operator* serves it at `/.well-known/webcat/enrollment.json` and submits every change to the *enrollment infrastructure*, which records its hash in the *canonical state* once the *cooldown* has elapsed.

#### Enrollment infrastructure

The enrollment infrastructure is WEBCAT's root of trust. It consists of the *enrollment chain*, the *oracles*, the enrollment frontend at [enroll.webcat.tech](https://enroll.webcat.tech), and the endpoints that publish the *preload list*. Independent *infrastructure operators* run its nodes, and every state change requires a 2/3 supermajority.

#### Enrollment chain

The enrollment chain is the append-only ledger at the core of the *enrollment infrastructure*. It is a permissioned [CometBFT](https://cometbft.com/) blockchain with a Rust execution layer named `felidae`. It has no token and serves only as a tamper-evident, multi-party database.

#### Canonical state

The canonical state maps each enrolled domain to the hash of its *enrollment information*. Two thirds of the *validators* agree on it, and the *browser extension* consults it to decide whether a domain is enrolled.

#### Preload list

The preload list is a signed snapshot of the *canonical state*, together with the block header and the Merkle proofs that authenticate it. The *enrollment infrastructure* publishes it for the *browser extension*, which accepts a list only if at least 2/3 of the validator set signed it and it is newer than the list already held.

#### Manifest

A manifest is a JSON document that lists a *web app*'s files and their hashes, its Content Security Policy, and related metadata. The developer signs it according to the domain's *trust policy* and records the signature in a *transparency log*. *webcat-cli* generates manifests.

#### Bundle

A bundle combines the *enrollment information*, the signed *manifest*, and the manifest's transparency log proofs in one JSON document. The site serves it at `/.well-known/webcat/bundle.json`, and it is the only per-site file the *browser extension* fetches. *webcat-cli* generates bundles.

#### Browser extension

The browser extension is the client-side component that verifies *web apps* in the *end user*'s browser. It is currently a Firefox extension distributed through Mozilla Add-ons. At startup and at regular intervals it downloads the *preload list*, uses it to verify each site's *enrollment information* and *manifest*, and then checks the integrity of every resource and of the Content Security Policy.

#### webcat-cli

webcat-cli is the command line tool that generates *enrollment information*, signs *manifests*, assembles *bundles*, and checks that a bundle verifies. Its source is in the [webcat-cli](https://github.com/freedomofpress/webcat-cli) repository.

#### Trust policy

The trust policy is the part of the *enrollment information* that states who may sign a *manifest* and under which conditions. For Sigsum it holds the authorized keys, the signature threshold, and the log and witness policy. For Sigstore it holds the trust root and the identity claims a certificate must carry.

#### Cooldown

The cooldown is the period during which a proposed *enrollment information* change is public but not yet applied. A new submission for the same domain during this period cancels the pending change. The cooldown lasts 1 day during the alpha stage and 7 days thereafter.

### Enrollment infrastructure roles

#### Node

A node is a machine that runs the *enrollment chain* software. It stores the full ledger and serves the query API. A node may or may not be a *validator*.

#### Validator

A validator is a *node* with voting power. The *enrollment chain* finalizes a block only when 2/3 of the validators participate. Joining the validator set requires manual authorization.

#### Oracle

An oracle is a service that fetches a domain's `enrollment.json` and posts a signed observation to the *enrollment chain*. A quorum of matching observations starts the *cooldown*.

#### Admin

An admin holds one of the offline keys that, as a quorum, configure the *enrollment chain*: voting parameters, quotas, and the *validator* and *oracle* sets. An admin is not a *site operator*.

### Existing components

#### Transparency log

A transparency log is an append-only, publicly verifiable record of signed statements, such as *manifest* signatures. It makes mis-issuance and equivocation detectable.

#### Sigsum

[Sigsum](https://sigsum.org/) is a transparency system built on simple logs and explicit witness cosigning. It does not rely on certificate authorities.

#### Sigstore

[Sigstore](https://sigstore.dev/) is a signing and transparency ecosystem that binds signatures to OIDC identities through short-lived certificates and public logs.

#### Content Security Policy (CSP)

[CSP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP) is an HTTP response header that restricts the sources from which a *web app* may load scripts, styles, workers, and other resources.

### Parties

*Web app developers* and *site operators* are distinct roles that the same entity often fills. A team that builds and hosts its own app performs both roles and reads both sections.

#### Web app developers

Web app developers build a static *web app* that meets the WEBCAT requirements. For each release they generate a *manifest*, sign it, and record the signature in a *transparency log*.

#### Site operators

Site operators publish the *web app*, its *enrollment information*, and its *bundle* on a domain they control. They configure the web server as the manifest requires and enroll the domain in the *enrollment infrastructure*.

#### WEBCAT contributors

WEBCAT contributors work on WEBCAT itself: the *browser extension*, *webcat-cli*, the *enrollment infrastructure*, the specification, or this documentation. See [For contributors](./contributors/README.md).

#### Infrastructure operators

Infrastructure operators are organizations, such as the Freedom of the Press Foundation, that run a *validator*, an *oracle*, or both.

#### End users

End users install the *browser extension*. The extension updates itself and runs without interaction. When verification fails, it blocks the page load and displays the reason.

#### Auditors and monitors

Auditors and monitors independently observe the *enrollment infrastructure* and the *transparency logs*. They alert developers and site operators to new signatures and to pending enrollment changes.

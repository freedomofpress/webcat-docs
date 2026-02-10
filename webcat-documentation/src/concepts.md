### Glossary

#### WEBCAT

 * **Enrollment information** A structured JSON document containing the WEBCAT enrollment data, as defined by the WEBCAT specification. Participating site operators MUST serve this document at `/.well-known/webcat/enrollment.json`, and MUST submit an update to the *enrollment system* every time it changes.
 The *enrollment system* performs basic validation and records a cryptographic hash of the enrollment information. After a mandatory *cooldown* period, during which the enrollment information MUST remain unchanged, the information is verified again and, if valid, committed to the *enrollment system*.

 * **Enrollment system** A distributed, consensus-based system acting as WEBCAT's root of trust. Nodes are operated by independent, trusted organizations, and all state-changing operations require approval by a 2/3 supermajority.
 The system maintains an append-only ledger, with every node storing a full copy. Its purpose is to validate, timestamp, and permanently record the *enrollment information* associated with each participating domain.
  Interactions with the enrollment system can be performed using the *WEBCAT CLI*.

 * **Manifest** A structured JSON document describing the integrity properties of a web application and its execution environment, according to the WEBCAT specification.
 Each manifest MUST be signed in accordance with the policy and trust material specified in the corresponding *enrollment information*.
  Manifests can be generated using the *WEBCAT CLI*.

 * **Bundle** A structured JSON document that combines the *enrollment information* and the *manifest* for a given web application.
 The bundle MUST be served at `/.well-known/webcat/bundle.json` and contains all the information required by the *WEBCAT browser extension* to perform integrity verification.
  Bundles can be generated using the *WEBCAT CLI*.

 * **Browser extension** The client-side component running in the end-user’s browser, responsible for verifying the integrity of a web application.
 At startup and at periodic intervals, the extension downloads a snapshot of the root of trust from the *enrollment system*. This snapshot is used to verify the authenticity and integrity of each website’s *enrollment information*, which in turn is used to validate the associated *manifest*.
 Once a manifest has been successfully validated and cached, the browser extension enforces integrity checks on all application resources and related metadata, including the Content Security Policy (CSP).

 * **Cooldown** A fixed time window during which a proposed *enrollment information* change for a given domain is publicly observable but not yet applied. During this period, the change is fully revertible.
 The cooldown duration is 1 day during the alpha stage and 7 days thereafter.

#### Existing Components

 - **Transparency Log** An append-only, publicly verifiable data structure that records signed statements (such as manifests) in a way that enables auditing, monitoring, and detection of mis-issuance or equivocation.

 - [**Sigsum**](https://sigsum.org/) A transparency system based on simple, auditable logs and explicit witness cosigning, designed to provide verifiable publication without relying on centralized certificate authorities.

 - [**Sigstore**](https://sigstore.dev/) A signing and transparency ecosystem that binds signatures to identities derived from federated identity providers (e.g., OIDC), typically using short-lived certificates and public transparency logs.

 - [**Content Security Policy (CSP)**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP) A web security mechanism, expressed as an HTTP response header, that restricts the origins from which a web application may load resources such as scripts, styles, and workers.



### Parties

 - **Developers** build a static web application that complies with the restrictions required for WEBCAT to operate securely. They publish *enrollment information* describing their signing identities and trust policy. For each release, they build the application, generate a *manifest* describing the release and its assets, sign it, and record it in a transparency log.

 - **Website administrators** who may also be developers, are responsible for publishing the web application, its *enrollment information*, and the corresponding *manifest*. They configure the web server to comply with parameters specified in the manifest, such as the default Content Security Policy and the default entry point (e.g., the index page). Website administrators are also responsible for enrolling their domain in the *WEBCAT enrollment system* and for signaling *enrollment changes* over time. 
 In centralized deployments, website administrators and developers are typically the same entity.

 - **Infrastructure operators** such as the Freedom of the Press Foundation (FPF), run components of the *WEBCAT enrollment system*. The enrollment system is a distributed, consensus-based system; no single operator has unilateral control over its state or decisions.

 - **End users** install the *WEBCAT browser extension*. The extension updates automatically at startup and at regular intervals and operates transparently during normal browsing. Only in the event of validation errors may page loads be blocked, in which case the user is notified. No additional user interaction is required.

 - **Auditors and monitors** independently audit and monitor both the *WEBCAT enrollment system* and any transparency logs used by developers. They may notify developers or website administrators when relevant actions occur, such as new signatures being recorded in a transparency log or requests to modify a website's enrollment information.

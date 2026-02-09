### Glossary
 - **Transparency Log** An append-only, publicly verifiable data structure that records signed statements (such as manifests) in a way that enables auditing, monitoring, and detection of mis-issuance or equivocation.

 - [**Sigsum**](https://sigsum.org/) A transparency system based on simple, auditable logs and explicit witness cosigning, designed to provide verifiable publication without relying on centralized certificate authorities.

 - [**Sigstore**](https://sigstore.dev/) A signing and transparency ecosystem that binds signatures to identities derived from federated identity providers (e.g., OIDC), typically using short-lived certificates and public transparency logs.

 - [**Content Security Policy (CSP)**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP) A web security mechanism, expressed as an HTTP response header, that restricts the origins from which a web application may load resources such as scripts, styles, and workers.

 - **Cooldown** A time window (1 day during alpha stage; 7 days afterwards) during which an *enrollment change* for a given domain is monitorable, but still not applied and fully revertable.

### Parties

 - **Developers** build a static web application that complies with the restrictions required for WEBCAT to operate securely. They publish *enrollment information* describing their signing identities and trust policy. For each release, they build the application, generate a *manifest* describing the release and its assets, sign it, and record it in a transparency log.

 - **Website administrators** who may also be developers, are responsible for publishing the web application, its *enrollment information*, and the corresponding *manifest*. They configure the web server to comply with parameters specified in the manifest, such as the default Content Security Policy and the default entry point (e.g., the index page). Website administrators are also responsible for enrolling their domain in the *WEBCAT enrollment system* and for signaling *enrollment changes* over time. 
 In centralized deployments, website administrators and developers are typically the same entity.

 - **Infrastructure operators** such as the Freedom of the Press Foundation (FPF), run components of the *WEBCAT enrollment system*. The enrollment system is a distributed, consensus-based system; no single operator has unilateral control over its state or decisions.

 - **End users** install the *WEBCAT browser extension*. The extension updates automatically at startup and at regular intervals and operates transparently during normal browsing. Only in the event of validation errors may page loads be blocked, in which case the user is notified. No additional user interaction is required.

 - **Auditors and monitors** independently audit and monitor both the *WEBCAT enrollment system* and any transparency logs used by developers. They may notify developers or website administrators when relevant actions occur, such as new signatures being recorded in a transparency log or requests to modify a website's enrollment information.

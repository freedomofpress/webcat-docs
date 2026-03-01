# Threat Model
The WEBCAT threat model distinguishes between attacks that the system aims to **prevent**, and those it aims to **detect**. The goal is to ensure that all targeted attacks are preventable, and that all large-scale attacks are detectable. An attack is deemed successful if it causes end-user compromise in which users loads client-side assets (such as HTML, JavaScript, WebAssembly, or CSS) that was not authored or intended by the application developers. WEBCAT assumes a powerful adversary whose capabilities may extend to include control over infrastructure and over signing identities of application developers. An attacker may compromise a server or take over one or more domains, depending on jurisdiction and technical capabilities. Services, companies, and individual servers are more at risk from attacks, even by small threat actors, than core infrastructure. Known examples include the [jabber.ru MITM attack](https://notes.valdikss.org.ru/jabber.ru-mitm/) and the [MyEtherWallet BGP hijacking](https://www.theverge.com/2018/4/24/17275982/myetherwallet-hack-bgp-dns-hijacking-stolen-ethereum), and likely many more cases that went unnoticed, despite being potentially detectable. The distinction between preventable and detectable attacks is a tradeoff between a heuristic estimate of the probability of real-world attacks and the complexity of infrastructure and design.

### Preventable
The system is designed to prevent end-user compromise even if an attacker gains control over:
 - **Web server**: Full control over the application server, including domain hijacking, BGP or MITM attacks, rogue TLS certificate issuance, or theft of TLS private keys (for a limited amount of time, < _cooldown_)
 - **WEBCAT infrastructure**: Up to 1/3 of the *WEBCAT enrollment system**'s nodes. Full control over the enrollment frontend, full control over the extension's CDN list update endpoint.
 - **Sigsum log**: Full control of the transparency log.
 - **Sigsum witnesses**: Up to threshold − 1 Sigsum witnesses.


*Note:* While Sigsum enrollment support threshold signing, Sigstore ones do not. Thus, a compromise of the Sisgstore identity provider, the Sigstore identity, or the CI infrastructure if in use does not

### Detectable
Detectability implies the existence of immutable, cryptographically verifiable evidence that an event has occurred, enabling third-party aduting and monitoring. We refer to *auditing* as the act of checking that a transparency log is behaving properly, and monitoring as checking in real-time or posthumously the information being appended to the log. The system guarantees detectability in the following cases of compromise:

 - **Targeted web application updates**: due to the transparency logging requirements, a single user cannot be targeted without signing and logging a release. It is up to monitors to check that source code and reproducibility is available for all versions of a web application.
 - **Extended web server compromise**: if a domain or a webserver are taken over for longer than the _cooldown_ period, then a malicious *enrollment change* can be successfully committed. However, cryptographic evidence will be preserved and available in the *WEBCAT enrollment system*.
 - **Sigstore Certificate infrastructure**: Unauthorized issuance by Fulcio still require transparency logging.
 - **Sigstore OIDC provider**: Equivalent to the **Sigstore Certificate infrastructure** case.
 - **Sigsum identities**: if more than *threshold* Sigsum identities are compromised according to the *enrollment information*, then a malicious application update can be shupped. However, non-repudiable information about the event will remain in the chosen Sigsum transparency log.

### Combined
*TODO: in some cases there's guarantees even when multiple components misbehave. We cannot cover all cases, but could be nice to highlight a few.*

### Out-of-scope
The following attacks are explicitly out of scope:
 - **WEBCAT supply chain**: Supply chain attacks or backdoors in the WEBCAT repositories. While we strive to apply proper supply chain security practices, such as dependency scanning, the system itself is not resisten to this type of threats. We are also limited by the underlying distribution platform, the Mozilla Addons platform (AMO), which currently does not support supply chain integrity validation or transparency logging.
 - **Application-level issues**: Vulnerabilities or malicious behavior in web applications.


## Censorship Risks

WEBCAT must not introduce additional single points of failure or censorship risks beyond those already inherent in hosting content on the internet. In short, WEBCAT must not become an easy or plausible target for censorship requests aimed at hindering websites from operating or from using WEBCAT itself.

At present, WEBCAT supports only traditional domain names. However, support for Onion Services is planned on the roadmap. In that context, the censorship threat model becomes even more complex, and the system must be designed accordingly.


### Censorship and the Enrollment System

The *WEBCAT enrollment system* is based on distributed consensus and requires a 2/3 majority to decide on enrollment (or non-enrollment). At the current alpha stage, the number of nodes is limited, and most are operated by the Freedom of the Press Foundation. This concentration represents a transitional configuration rather than a long-term situation.

Beyond the alpha phase, the objective is to distribute the infrastructure across a broader ecosystem of trusted organizations that are geographically and jurisdictionally diverse. Even a distribution comparable in size to that of the Tor Directory Authorities (n=10) could provide a meaningful deterrent against coercion or censorship attempts.

### Censorship and Transparency Logs (Sigstore and Sigsum)
Transparency logs, such as Sigstore and Sigsum, may theoretically be in a position to block a project from logging new manifests, thereby preventing updates to a web application. Such blocking could be a direct threat (e.g., refusal to log entries) or indirect (e.g., freezing attacks that prevent timely updates).

While no documented cases of direct blocking are known to us, indirect forms of interference are plausible. For example, GitHub might suspend a project or user relying on Sigstore-based enrollment via CI workflows. Similarly, an OIDC provider might revoke access for a user relying on identity-based signing in Sigstore.

WEBCAT is designed to mitigate such risks. No Sigstore trust root or Sigsum log is hardcoded into the system. Instead, website administrators define their trust root and policy at enrollment time. This provides flexibility in case of platform-level interference. For instance:

* A project banned from GitHub can migrate to another repository provider.
* A project can switch to a different OIDC provider.
* A project can transition from Sigstore-based enrollment to a Sigsum-based model.
* Administrators may host their own Sigsum log while still benefiting from multi-party security through the [witness network](https://witness-network.org/).

Although such migrations may be inconvenient, they remain technically possible without requiring changes to the WEBCAT protocol itself, or updates to the browser extension.

More broadly, we expect that censorship actors would find it easier to target DNS providers, domain registrars, or hosting platforms directly in order to achieve a takedown. WEBCAT operates as an additional verification layer on top of these systems and is, by design, less centralized than many of the infrastructures it relies upon.

### Censorship and the Browser Extension
It is possible that WEBCAT update endpoints, currently hardcoded in the browser extension, could be blocked in certain jurisdictions. To mitigate this risk, each extension release bundles the most recent enrollment and update data, providing a fallback channel independent of runtime network access.

The update mechanism may evolve in the future to reduce update frequency and bandwidth requirements, further minimizing exposure to network-level blocking. Moreover, update endpoints can be modified through regular extension updates.

Importantly, these endpoints are not inherently easier targets for censorship than the browser's add-on store or the browser update infrastructure itself. Any actor capable of blocking WEBCAT update endpoints would likely also be capable of blocking the broader extension distribution ecosystem.

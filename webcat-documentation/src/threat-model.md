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

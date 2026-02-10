# Censorship

The backend infrastructure is decentralized due to censorship risk. By using a decentralized system,
there are no single points of failure, and there is shared trust/liability across jurisdictions. This
comes at the cost of a more complex setup, both in terms of social coordination overhead as well as technically
by using a consensus system. Frontends submitting to the chain also must rate-limit, and the chain also
limits per domain how many subdomains can be enrolled.

Organizations like the Freedom of the Press Foundation, Tor Project, and others - ideally across different jurisdictions (e.g., Tor relay associations) - would run validator nodes on low-cost VPSes or on-premises hardware (from ~$5/month). There is native support for using (cloud) HSMs if needed.

Each organization may offer a web interface for submission to their local node, secured with CAPTCHA or basic rate-limiting. The receiving node performs validation and broadcasts the transaction to the rest of the network.

To fake or force an enrollment operation, an attacker would need control of at 2/3 validator nodes. The enrollment preload list cannot be forged or censored, as clients (the WEBCAT Browser Extension) requires a valid network consensus. Thus, only a majority of nodes (or the organizations behind them) could alter the enrollment preload list content.

1. Routing foundation
Set up hostapd + dnsmasq so the Pi is a working AP. Clients connect, get IPs via DHCP with the Pi as their DNS server. Enable IP forwarding. Verify internet works through the Pi. Document: network diagram, config files with inline comments, ip route and ip addr outputs.

2. DNS filtering (Pi-hole)
Install Pi-hole. Configure it as the upstream resolver for dnsmasq (or replace dnsmasq with Pi-hole's built-in). Test blocking. Research question: what percentage of traffic is stopped here vs. what bypasses it? Document: Pi-hole blocklist sources, query log schema, false positive rate.

4. IP filtering (nftables)
Write nftables rules to block by IPv4/IPv6 address and CIDR range. Use nft sets for efficient list management (you'll have thousands of IPs). Block UDP/443 to suppress QUIC. Document: nftables ruleset with comments, performance benchmarks (pps under load on Pi hardware).

5. SNI filtering (HAProxy)!
Configure TPROXY in nftables to redirect port 443 TCP to HAProxy. HAProxy inspects the SNI and either proxies the connection onward (passthrough) or rejects it. Document: HAProxy frontend config, SNI ACL lists, what happens to non-TLS traffic on port 443.

6. DoH/QUIC blocking
Identify DoH resolver IPs (Cloudflare, Google, NextDNS, etc.) and block them in nftables. Study what happens with ECH. Research question: can a client using a mobile browser with DoH+ECH bypass all your filters? Document: DoH endpoint inventory, bypass success matrix.

7. Measurement and analysis
Run structured tests:for each filtering layer, attempt access to blocked domains using various client configurations (default browser, Firefox with DoH, curl with DoH, custom DoH client). Build a results matrix. This is your thesis data.
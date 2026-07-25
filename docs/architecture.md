Raspi: NetworkManager· wlan0 (AP) / eth0 (uplink)
1. DNS filtering
Pi-hole · blocks by domain · sinkhole
2. IP filtering
nftables · IPv4 + IPv6 sets · drop / tc
3. QUIC / DoT / DoH (partial) block
drop UDP/443 · drop TCP/853 · block DNS resolver IPs

Could replace sinkhole with nxdomain?

I have CLI for fw-censor. But how can I activate/deactivate piholes blocklist?

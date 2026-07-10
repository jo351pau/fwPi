Raspi: NetworkManager· wlan0 (AP) / eth0 (uplink)
1. DNS filtering
Pi-hole · blocks by domain · NXDOMAIN / sinkhole
2. IP filtering
nftables · IPv4 + IPv6 sets · drop / reject
3. QUIC / DoH block
drop UDP/443 · block DoH resolver IPs

chmod +x run_tests.sh

./run_tests.sh

ToDo
- Dns bypass could be better
- ip_block,v4,3.251.50.149,1,rules_off,2067,0
  ip_block,v4,54.155.178.5,1,rules_off,2072,0
  ip_block,v4,54.74.73.31,1,rules_off,2066,0 why cant I ping Netflix from Eduroam

dns_interception.sh    # DNS forced to Pi-hole
dns_bypass.sh          # Attempts to bypass Pi-hole
ip_block.sh            # IPv4 and IPv6 firewall rules
dot_block.sh           # DNS-over-TLS tests
quic_block.sh          # QUIC tests
latency.sh             # Ping/RTT baseline
throughput.sh          # iperf3 benchmark TODO!!!!
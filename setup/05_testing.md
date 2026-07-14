# Testing

``bash
$ chmod +x run.sh
$ ./run.sh
``
This has been set up for MacOS (sorry). But can be used for Linux aswell with few alterations in ```/testing/config.s``h:
- Adjust the basedirectory BASE_DIR
- Adjust the command for pinging IOv6 addresses V6_PING_CMD
- Adjust RUN_PING
- Adjust the curl command for http3/QUIC traffic CURL

ToDo
- Dns bypass could be better
- ip_block,v4,3.251.50.149,1,rules_off,2067,0
  ip_block,v4,54.155.178.5,1,rules_off,2072,0
  ip_block,v4,54.74.73.31,1,rules_off,2066,0 why cant I ping Netflix from Eduroam
- make nftables modular st blcoking can be added or not
- do the math for latency
- put everything from csv into nice tables

### Layer 1 — Pi-hole DNS filtering
dns_interception.sh    
DNS forced to Pi-hole

dns_bypass.sh          
Attempts to bypass Pi-hole
-----------------
```bash
# allowed domain resolves correctly
dig google.com @192.168.8.1
# expected: real IP returned, status NOERROR

# blocked domain returns zero address
dig facebook.com @192.168.8.1
# expected: 0.0.0.0 returned, check pihole -t shows "blocked"

# Pi-hole is intercepting hardcoded DNS (NAT redirect test)
# manually point dig at Google's resolver
dig google.com @8.8.8.8
# expected: resolves correctly — but check pihole -t
# the query should appear in Pi-hole's log even though
# you addressed it to 8.8.8.8 — proves NAT redirect works

dig facebook.com @8.8.8.8
# expected: 0.0.0.0 — Pi-hole intercepted it despite @8.8.8.8

# DoH bootstrap domains blocked
dig dns.google @192.168.8.1
dig cloudflare-dns.com @192.168.8.1
# expected: both return 0.0.0.0
```
### Layer 2 — nftables IP blocking
ip_block.sh            
IPv4 and IPv6 firewall rules
------------
```bash
# known DNS resolver IPs are blocked
ping -c3 1.1.1.1
ping -c3 8.8.8.8
ping -c3 9.9.9.9
# expected: all time out — check dmesg shows DROP dns_ipv4

# IPv6 DNS resolvers blocked (if tunnel is up)
ping6 -c3 2606:4700:4700::1111
ping6 -c3 2001:4860:4860::8888
# expected: dropped

# non-blocked IPs still reachable
ping -c3 142.250.185.46    # google.com
ping -c3 93.184.216.34     # example.com
# expected: replies

# CURL by IP — no DNS involved
# allowed:
curl -v --connect-timeout 5 \
    --resolve google.com:443:142.250.185.46 \
    https://google.com
# expected: TLS handshake succeeds, content returned

# blocked IP (facebook):
curl -v --connect-timeout 5 \
    --resolve facebook.com:443:31.13.84.36 \
    https://facebook.com
# expected: times out or refused
# note: this tests IP blocking only — if 31.13.84.36 is not
# in your deny_ipv4 set this will succeed — that is the
# direct IP bypass gap, document it as a finding
```
### Layer 3 — Protocol blocking (DoT and QUIC)
dot_block.sh
DNS-over-TLS tests TODO To slowwwwwww

quic_block.sh
QUIC tests
-----------
```bash
# install kdig for DoT testing
brew install knot-resolver

# DoT blocked (port 853)
kdig -d @8.8.8.8 +tls google.com
# expected: connection times out — dmesg shows DROP DoT

# confirm normal DNS still works (port 53 unaffected)
dig google.com @192.168.8.1
# expected: resolves normally

# QUIC suppression — check browser falls back to HTTP/2
# install curl with HTTP/3 support
brew install curl-openssl

# attempt HTTP/3 (QUIC)
/usr/local/opt/curl/bin/curl -v --http3 https://google.com 2>&1 \
    | grep -E "QUIC|HTTP/|Connected"
# expected: falls back to HTTP/2 over TCP
# dmesg shows DROP QUIC UDP/443

# confirm TCP/443 still works (QUIC block does not break HTTPS)
curl -v https://google.com
# expected: connects over TCP, HTTP/2
```
### Layer 4 — End to end blocking behavior
```bash
# full browser simulation — blocked domain
curl -v --max-time 10 https://facebook.com
# expected: DNS returns 0.0.0.0, curl cannot connect
# pihole -t shows: facebook.com blocked

# full browser simulation — allowed domain
curl -v --max-time 10 https://google.com
# expected: full TLS handshake, HTTP response

# check what Pi-hole logs for a normal browsing session
# open Safari, visit a few sites, watch pihole -t
# you will see every DNS query the browser makes
# including CDN subdomains, analytics, tracking pixels

# test Pi-hole blocking a domain mid-session
# visit a site, note what gets blocked in pihole -t
# this shows collateral blocking (CDN, analytics on
# the same domain) — document for thesis
```
### Layer 5 — Bypass attempt documentation (thesis data)
```bash
# bypass attempt 1: hardcoded DNS resolver IP
# change Mac DNS manually:
networksetup -setdnsservers Wi-Fi 8.8.8.8
dig facebook.com
# expected: still blocked — NAT redirect intercepts it
# revert after test:
networksetup -setdnsservers Wi-Fi 192.168.8.1

# bypass attempt 2: DoH via Firefox
# Firefox preferences → Network Settings → Enable DNS over HTTPS
# set provider to Cloudflare
# visit facebook.com in Firefox
# expected: blocked — cloudflare-dns.com in Pi-hole blocklist
#           AND 1.1.1.1 in nftables IP blocklist
# check pihole -t — does Firefox's DoH query appear?
# if not: DoH bypassed Pi-hole (expected)
# if yes: NAT redirect caught it

# bypass attempt 3: direct IP access
curl -v --connect-timeout 5 \
    --resolve facebook.com:443:31.13.84.36 \
    https://facebook.com
# expected: depends on whether 31.13.84.36 is in deny_ipv4
# if NOT in list: connection succeeds — this is your documented gap
# add to list:
# sudo /usr/local/bin/add_to_blocklist.sh facebook.com
# retest — should now be blocked

# bypass attempt 4: different blocked domain via direct IP
host instagram.com
# take the returned IP and:
curl -v --connect-timeout 5 \
    --resolve instagram.com:443:<IP> \
    https://instagram.com
# document result

# bypass attempt 5: IPv6 path (if tunnel up)
# disable IPv4 temporarily on Mac:
networksetup -setv4off Wi-Fi
curl -v https://google.com
# expected: works via IPv6 if tunnel configured correctly
# revert:
networksetup -setmanual Wi-Fi 192.168.8.100 255.255.255.0 192.168.8.1
```

### latency.sh             
Ping/RTT baseline TODO the math

### throughput.sh          
iperf3 benchmark TODO!!!!
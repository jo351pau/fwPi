#!/usr/bin/env bash

sudo cp config/nftables/ /etc/nftables
sudo cp /etc/nftables/nftables.conf /etc/nftables.conf

# sudo cp config/nftables/censorship.nft /etc/nftables/censorship.nft
# sudo cp config/nftables/throttle.nft /etc/nftables/throttle.nft
# sudo cp config/nftables/nft_sets/deny_ipv4.txt /etc/nftables/nft_sets/
# sudo cp config/nftables/nft_sets/deny_ipv6.txt /etc/nftables/nft_sets/
# sudo cp config/nftables/nft_sets/deny_ipv4_dns.txt /etc/nftables/nft_sets/
# sudo cp config/nftables/nft_sets/deny_ipv6_dns.txt /etc/nftables/nft_sets/

sudo cp config/my_blocklist.txt /etc/pihole/
# sudo cp config/my_allowlist.txt /etc/pihole/

sudo cp fwPiCLI /usr/local/bin/fwPiCLI/
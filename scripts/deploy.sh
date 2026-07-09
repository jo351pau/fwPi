#!/usr/bin/env bash

sudo cp config/nftables.conf /etc/nftables.conf

sudo cp config/deny_ipv4.txt /etc/nftables/
sudo cp config/deny_ipv6.txt /etc/nftables/
sudo cp config/deny_ipv4_dns.txt /etc/nftables/
sudo cp config/deny_ipv6_dns.txt /etc/nftables/

sudo cp config/my_blocklist.txt /etc/pihole/
sudo cp config/my_allowlist.txt /etc/pihole/
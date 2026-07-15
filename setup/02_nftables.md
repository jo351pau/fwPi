# Getting started with nftables

``$ systemctl enable nftables``

``$ systemctl start nftables``

Validate syntax without applying: ``$ nft -c -f /etc/nftables.conf``

Apply: ``$ sudo nft -f /etc/nftables.conf``

Verify the full loaded ruleset: ``$ nft list ruleset``

Make nftables wait for network interfaces: ``$ systemctl edit nftables.service``
```
[Unit]
After=NetworkManager.service
Wants=NetworkManager.service
```
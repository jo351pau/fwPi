# Pi-hole

Install Pi-hole and follow set up: ``$ curl -sSL https://install.pi-hole.net | bash``

Configure Pi-hole as DNS Server using static IP addresses from LAN_IF:
``IPv4: 128.130.39.108``
``IPv6: fd79:2cbd:da3c::``

Log into web interface at http://128.130.39.108:80/admin.

Enable Pi-holes DHCP Server and set Range: ``192.168.50.10 - 192.168.50.200``

Router (Gateway): ``192.168.50.1``

Enable IPv6 support

Add my_blocklist and my_allowlist to subscribed lists group management.
``file:///usr/local/lib/fwPi/config/pihole/my_blocklist.txt``

``pihole -g``
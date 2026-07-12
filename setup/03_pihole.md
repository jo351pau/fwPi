# Pi-hole

Install Pi-hole and follow set up: ``$ curl -sSL https://install.pi-hole.net | bash``

Configure Pi-hole as DNS Server using static IP addresses:
``IPv4: 128.130.39.108`` why
``IPv6: fd79:2cbd:da3c::`` oder 2a06:d1c1:ee:1::1??

Log into web interface at http://128.130.39.108:80/admin.

Enable Pi-holes DHCP Server and set Range: ``192.168.50.10 - 192.168.50.200``

Router (Gateway): ``192.168.50.1``

Enable IPv6 support

Create ``file:///etc/pihole/my_blocklist.txt`` and add to subscribed lists group management.
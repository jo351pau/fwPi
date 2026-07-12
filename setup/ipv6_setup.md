# IPv6 setup
#### This is how PI reaches IPv6 Internet through the tunnel:
```bash
$ ip a add 2a06:d1c1:ef::2/64 dev eth0
$ ip -6 route add default via 2a06:d1c1:ef::1
$ ip a add 2a06:d1c1:ee::23/128 dev lo
```
verify with ``$ ip -6 route show``

making it permanent:
```bash
nmcli con modify netplan-eth0 ipv6.method manual \
  ipv6.addresses 2a06:d1c1:ef::2/64 \
  ipv6.gateway 2a06:d1c1:ef::1
nmcli con up netplan-eth0
nmcli con modify lo con-name lo-ipv6 ipv6.method manual \
  ipv6.addresses 2a06:d1c1:ee::23/128
nmcli con up lo-ipv6
```

should give you:
default via 2a06:d1c1:ef::1 dev eth0
2a06:d1c1:ef::/64 dev eth0
2a06:d1c1:ee:1::/64 dev wlan0

Try pinging wikipedia.org: ``ping6 2a06:d1c1:ee:1::1``

#### Getting IPv6 connectivity for fwAccessPoint / wlan0 Interface:
2a06:d1c1:ee::/48 # my network
```bash
$ ip addr add 2a06:d1c1:ee:1::1/64 dev wlan0 # assigns router address
```
```bash
nmcli con modify "fwAccessPoint" ipv6.method manual \
  ipv6.addresses "2a06:d1c1:ee:1::1/64"
nmcli con up "fwAccessPoint"
```
install radvd

In ```/etc/radvd.conf```: 
```bash
interface wlan0
{
    AdvSendAdvert on; # Enable Router Advertisements.
    
    prefix 2a06:d1c1:ee:1::/64 {
        AdvOnLink on; # Tell clients this prefix is directly reachable on the local network.
        AdvAutonomous on; # Enable SLAAC
        AdvRouterAddr on; # Advertise the router's own address as valid
    };

    RDNSS 2a06:d1c1:ee:1::1 {}; # Advertise the Pi as the IPv6 DNS server. If Pi-hole is listening on IPv6, macOS will automatically use it.
};
```
On Mac make sure, that you go to Wifi and edit the connection fwAccessPpint->TCP/IP->Configure IPv6->automatic. 
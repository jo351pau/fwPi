### Set up Access Point with nmcli

```bash
$ nmcli connection add type wifi ifname wlan0 con-name fwAccessPoint \
ssid fwAccessPoint \
autoconnect yes \
802-11-wireless.mode ap \
802-11-wireless.band bg \
ipv4.method manual ipv4.address 192.168.50.1/24 \
ipv6.method manual ipv6.address fd79:2cbd:da3c::/64 \
wifi-sec.key-mgmt wpa-psk \
wifi-sec.psk "password"
```
Bring AP up: ```$ nmcli connection up fwAccessPoint```

Check if everything is set up correctly in the config file:
```/etc/NetworkManager/system-connections/fwAccessPoint.nmconnection```

```
[connection]
id=fwAccessPoint
uuid=********-****-****-****-************
type=wifi
interface-name=wlan0

[wifi]
band=bg
mac-address-blacklist=
mode=ap
ssid=fwAccessPoint

[wifi-security]
key-mgmt=wpa-psk
psk=password

[ipv4]
address1=192.168.50.1/24
method=manual

[ipv6]
addr-gen-mode=default
address1=fd79:2cbd:da3c::/64
method=manual

[proxy]
````

### Enable ip forwarding
``/etc/nftables.conf``

```
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```
```$ sysctl --load /etc/sysctl.conf```

Check if you can connect from client device and try to ping. If there is an issue maybe adjust your Wifi Country Code or reanable ip forwarding with ``$ sysctl -p``

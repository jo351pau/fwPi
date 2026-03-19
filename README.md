# fwPi

``/etc/nftables.conf``

```bash
#!/usr/sbin/nft -f

flush ruleset
include "/etc/fwPi/filter_table.conf"
```

``sudo haproxy -f /etc/fwPi/haproxy.cfg`` 
or 
``include /etc/fwPi/HAproxy.cfg``at the top of `/etc/haproxy/haproxy.cfg`
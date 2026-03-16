# fwPi

``/etc/nftables.conf``

```bash
#!/usr/sbin/nft -f

flush ruleset
include "/etc/fwPi/filter_table.conf"
```
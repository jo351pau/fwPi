# Linux traffic control
tc is being handled by the fwPiCLI

### Packet marking for tc throttling
nftables is changed to accomodate a mangling table. 
Rate limits are based on marks: 0x1 = throttle

### tc enforces rate limits based on marks

1. The data struct is setup with qdisc htb (for bandwidth regulation) and default redirect to 1:10 as root 1:
2. Then base class is setup as 1:1
3. Non throttling class 1:10 and throttling class 1:20 have 1:1 as parent
4. For the throttling class 1:20 there is a child leave qdisc 20:20 netem (packet timing) taking care of throttling latency
5. Last but not least there are two filter (ip/ipv6) on handle 1 directing traffic from parent 1: to throttling class 1:20


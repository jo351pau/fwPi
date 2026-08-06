# fwPi

### Missing:
#### git/code
1. Blocking in Base mode:
   - dot_block, base, v4: 100% flagged blocked, tcp/853 **mysterious magic** -> DoT is perfectly fine when connected with eduroam or using ipv6. But when connected to the AP, openssl and nc do not connect with 853. Tcpdump shows, SYN packets being send (no ACK) and nftables counter for forward chain general accept increases.
   - doq_block, base, v4: 100% flagged blocked, udp/853 upstream issue -> No UDP/853 connection possible. Test does not pass even when connecting to eduroam wifi and WAN
   - doq_block, base, v6: 77% blocked because the resolvers are not resolving
   
2. IPv4/IPv6 asymmetry under tc looks like a rate-limiting bug, not intended throttling behavior.
   Under tc, IPv4 traffic for both ip_block (100% blocked, ~2070ms !!nearly identical to td's hard-block latency) and dot_block (100% "blocked", ~3070ms) behaves indistinguishably from a hard drop, while the equivalent IPv6 traffic mostly succeeds at reduced speed (ip_block 25%, dot_block 0%, both with visibly elevated but bounded latency). 

#### overleaf/write
- choose between "throttling"/"rate limiting" and "traffic shaping"

==========================================================
==========================================================
 
Download rasp Imager and prepare micro SD with Raspian Trixie

### Setup and Lifecycle Management

#### Set up static IPv4/IPv6 LAN address

#### Installation
cd to where you want to have your local git repo
```bash
mkdir fwPi
# create new git repo
git init
# clone project into repo
git clone -b Working https://github.com/jo351pau/fwPi.git
# make setup scripts executable
chmod +x /setup
# copy fwPi to lib, copy nftables.conf and make backup, create symlink for fw-censor and make executable
./setup/install
```

#### Update
cd into your local git repo
```bash
# resets local changes and pulls the newest update from git
./setup/update 
```

#### Remove
cd into your local git repo
```bash
# removes symlink, clears lib and runtime nftable restored to preinstall backup
./setup/uninstall 
```


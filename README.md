# fwPi

### ToDo:
#### Tests
1. Blocking in Base mode:
   - dot_block, base, v4: 100% flagged blocked, tcp/853 **mysterious magic** -> DoT is perfectly fine when connected with eduroam or using ipv6. But when connected to the AP, openssl and nc do not connect with 853. Tcpdump shows, SYN packets being send (no ACK) and nftables counter for forward chain general accept increases.
   - doq_block, base, v4: 100% flagged blocked, udp/853 upstream issue -> No UDP/853 connection possible. Test does not pass even when connecting to eduroam wifi and WAN
   - doq_block, base, v6: 77% blocked because the resolvers are not resolving
     - AdGuard launched the first DoQ public resolver in 2020: https://adguard.com/en/blog/adguard-3-6-for-android.html#dnsoverquicsupport
       In March 2026 Quad9 enabled DoQ: https://quad9.net/news/blog/quad9-enables-dns-over-http-3-and-dns-over-quic/
   
2. IPv4/IPv6 asymmetry gets worse for IP filter. Due to IPv6 not being native on the uni network???

#### overleaf
- choose between "throttling"/"rate limiting" and "traffic shaping"

============================================
============================================
 
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


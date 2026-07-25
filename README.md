# fwPi

### Missing:
#### git/code
- Dpi/SNI (not happening right now) but some doh is filtered
- systematic Tests for fw-censor tc with iperf3
- Figure out what to do with those annoyingly slow timeouts
- Up the REPS counter to average data and collect in csv

#### overleaf/write
- make tables for tc
- add explainers on ip/tcp/dns/http etc.
- Add a 'structure' section at the end of the Intro
- figure out the research question and subquestion
- redo discussion to answer research questions
- redo conclusion to feature discussion
- work on layout of tables 
- make a figure of architecture
- figure the figures in overleaf
- edit the front pages

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


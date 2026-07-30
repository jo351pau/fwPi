# fwPi

### Missing:
#### git/code
1. Base mode shows non-zero blocking
   ip_block, base, v4: 3/11 targets flagged blocked (27.3%), all ~2070ms.
   ip_block, base, v6: 2/8 targets flagged blocked (25.0%), both ~11,100ms.
   dot_block, base, v4: 100% flagged blocked, ~3080ms — all three DoT targets fail even with no filtering active. This is a real problem: your thesis repeatedly states base disables all filtering. Either these specific targets are independently unreachable (dead hosts, upstream ISP issues, or a misconfigured baseline run), or base wasn't actually clean during this run.
   I'd suggest re-verifying the firewall state before the base trials, or re-running just these specific targets, before reporting them as your control condition.

2. IPv4/IPv6 asymmetry under tc looks like a rate-limiting bug, not intended throttling behavior.
   Under tc, IPv4 traffic for both ip_block (100% "blocked", ~2070ms — nearly identical to td's hard-block latency) and dot_block (100% "blocked", ~3070ms) behaves indistinguishably from a hard drop, while the equivalent IPv6 traffic mostly succeeds at reduced speed (ip_block 25%, dot_block 0%, both with visibly elevated but bounded latency).

3. Your design chapter's claim that tc "marks and shapes rather than drops" is not well supported by the IPv4 numbers as measured. Plausible explanations: the IPv4 tc class may be configured with a far lower effective rate than IPv6, or the test's timeout threshold is shorter than the time IPv4 connections need at the configured rate — meaning throttling and blocking become functionally indistinguishable from the client's perspective at low enough rates. Either way, this is a finding, not just noise — but it needs to be described as a measured result and possibly investigated (check your tc class definitions for v4 vs. v6) before you write it up as design confirmation.

4. DoH under tc shows the throttling effect nicely, but the "blocked" flag is nearly meaningless there.
   Only 7–11% of trials are flagged "blocked," yet mean latency (1450–1505ms) is roughly 10× the baseline (121–179ms). This is exactly the "incidental degradation without hard blocking" story you want for RQ3/RQ4 — but it means the binary blocked/bypassed framing in the Bypass Resistance table undersells what's happening. Worth adding a sentence in your Results prose citing the latency increase directly, not just the flag percentage.

Still missing (not present in this CSV)
Throttling Accuracy table: no data here sweeps across the three configured rates (64kbit/256kbit/1Mbit) — this file appears to reflect a single fixed tc rate used across the other scenarios, not the dedicated rate-sweep experiment.
Performance Overhead table: ICMP RTT baseline (ping, not embedded in any of these tests) and CPU utilization are not in this dataset. You'll need separate measurements for those two columns.

- Should I ommit reload command?

#### overleaf/write 
- make a figure of layered censorship architecture and figure of tc qdisc/classes tree an look at existing testbed architecture fig
- choose between throttling"/"rate limiting" and traffic shaping



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


#!/usr/bin/env bash
#
# run_tests.sh
# IPv4/IPv6 tests for the censorship testbed.
#
# IMPORTANT: Run this ON THE CLIENT connected to the Pi's AP,
# NOT on the Pi itself.
#
# Before running, verify your default route actually goes through the Pi:
#   netstat -nr | grep default      (check both v4 and v6 lines)
# Usage:
#   ./run_tests.sh

set -u

OUTFILE="results_$(date +%Y%m%d_%H%M%S).csv"
REPS=10                 # repetitions per test for averaging
IFACE="eth0"            # interface used for throttling/throughput tests
THROTTLE_RATE="1mbit"   # to be adjusted

BASE_DIR="/Users/johannapauler/Desktop/fwPi/config"

BLOCKLIST="$BASE_DIR/my_blocklist.txt"
ALLOWLIST="$BASE_DIR/my_allowlist.txt"

DENY_IPV4="$BASE_DIR/deny_ipv4.txt"
DENY_IPV6="$BASE_DIR/deny_ipv6.txt"

# --- Test targets ---
BLOCKED_DOMAINS=()
ALLOWED_DOMAINS=()
BLOCKED_IP4=()
BLOCKED_IP6=()

# --- Import Lists --
import_lists() {

    # --- Domains ---
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        [[ -n "$line" ]] && BLOCKED_DOMAINS+=("$line")
    done < "$BLOCKLIST"


    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        [[ -n "$line" ]] && ALLOWED_DOMAINS+=("$line")
    done < "$ALLOWLIST"

    # --- IPv4 ---
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | sed 's/,//' | xargs)
        [[ -n "$line" ]] && BLOCKED_IP4+=("$line")
    done < "$DENY_IPV4"

    # --- IPv6 ---
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | sed 's/,//' | xargs)
        [[ -n "$line" ]] && BLOCKED_IP6+=("$line")
    done < "$DENY_IPV6"
}

echo "test_type,stack,target,trial,rules_state,result_ms,success" > "$OUTFILE"

log() { echo "$(date '+%H:%M:%S') $*"; }

# Ms-precision timestamp
now_ms() { python3 -c 'import time; print(int(time.time()*1000))'; }

# "time=X" extractor
extract_time() {
  echo "$1" | sed -nE 's/.*time[=<]([0-9.]+).*/\1/p' | head -n1
}

run_ping() {
  local cmd=$1 target=$2
  if command -v timeout >/dev/null 2>&1; then
    timeout 3 $cmd -c 1 "$target" 2>/dev/null
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout 3 $cmd -c 1 "$target" 2>/dev/null
  else
    $cmd -c 1 "$target" 2>/dev/null
  fi
}

V6_PING_CMD="ping -6"

# --- DNS resolution test (A / AAAA) ---
test_dns() {
  local domain=$1 rtype=$2 stack=$3 expect=$4 state=$5
  for ((i=1; i<=REPS; i++)); do
    start=$(now_ms)
    if dig +short +time=2 +tries=1 "$rtype" "$domain" | grep -qE '.'; then
      resolved=1
    else
      resolved=0
    fi
    end=$(now_ms)
    ms=$(( end - start ))
    success=0
    [[ "$resolved" == "$expect" ]] && success=1
    echo "dns_${rtype},${stack},${domain},${i},${state},${ms},${success}" >> "$OUTFILE"
  done
}

# --- IP reachability test (v4/v6) ---
test_ip_block() {
  local ip=$1 stack=$2 pingcmd=$3 state=$4
  for ((i=1; i<=REPS; i++)); do
    start=$(now_ms)
    out=$(run_ping "$pingcmd" "$ip")
    if [[ -n "$out" ]] && echo "$out" | grep -qE 'bytes from|time[=<]'; then
      reachable=1
    else
      reachable=0
    fi
    end=$(now_ms)
    ms=$(( end - start ))
    # success = correctly BLOCKED (i.e. unreachable) when rules are on
    success=0
    if [[ "$state" == "rules_on" && "$reachable" == 0 ]]; then success=1; fi
    if [[ "$state" == "rules_off" && "$reachable" == 1 ]]; then success=1; fi
    echo "ip_block,${stack},${ip},${i},${state},${ms},${success}" >> "$OUTFILE"
  done
}

# --- Baseline latency test (no blocking involved, just RTT) ---
test_latency() {
  local target=$1 stack=$2 pingcmd=$3 state=$4
  for ((i=1; i<=REPS; i++)); do
    out=$(run_ping "$pingcmd" "$target")
    ms=$(extract_time "$out")
    [[ -z "$ms" ]] && ms=-1
    success=1
    [[ "$ms" == "-1" ]] && success=0
    echo "latency,${stack},${target},${i},${state},${ms},${success}" >> "$OUTFILE"
  done
}

# --- Throughput test via iperf3 (requires an iperf3 server reachable) ---
test_throughput() {
  local server=$1 stack=$2 flag=$3 state=$4
  local out mbits
  out=$(iperf3 -c "$server" $flag -t 5 2>/dev/null)
  mbits=$(echo "$out" | grep -m1 "receiver" | grep -oP '[0-9.]+(?= Mbits/sec)')
  [[ -z "$mbits" ]] && mbits=-1
  echo "throughput,${stack},${server},1,${state},${mbits},$( [[ "$mbits" != "-1" ]] && echo 1 || echo 0 )" >> "$OUTFILE"
}

log "=== Baseline pass (rules OFF) — remember to disable nftables rules/Pi-hole blocking before this runs ==="
read -p "Rules disabled? Press enter to continue..." _

for d in "${BLOCKED_DOMAINS[@]}"; do
  test_dns "$d" "A"    "v4" 1 "rules_off"
  test_dns "$d" "AAAA" "v6" 1 "rules_off"
done
for d in "${ALLOWED_DOMAINS[@]}"; do
  test_dns "$d" "A"    "v4" 1 "rules_off"
  test_dns "$d" "AAAA" "v6" 1 "rules_off"
done
for ip in "${BLOCKED_IP4[@]}"; do test_ip_block "$ip" "v4" "ping"  "rules_off"; done
for ip in "${BLOCKED_IP6[@]}"; do test_ip_block "$ip" "v6" "$V6_PING_CMD" "rules_off"; done

test_latency "1.1.1.1" "v4" "ping"  "rules_off"
test_latency "2606:4700:4700::1111" "v6" "$V6_PING_CMD" "rules_off"

# test_throughput "IPERF_SERVER_V4" "v4" "" "rules_off"
# test_throughput "IPERF_SERVER_V6" "v6" "-6" "rules_off"

log "=== Treatment pass (rules ON) — enable nftables rules/Pi-hole blocking now ==="
read -p "Rules enabled? Press enter to continue..." _

for d in "${BLOCKED_DOMAINS[@]}"; do
  test_dns "$d" "A"    "v4" 0 "rules_on"   # expect blocked -> no resolution
  test_dns "$d" "AAAA" "v6" 0 "rules_on"
done
for d in "${ALLOWED_DOMAINS[@]}"; do
  test_dns "$d" "A"    "v4" 1 "rules_on"   # still expected to resolve
  test_dns "$d" "AAAA" "v6" 1 "rules_on"
done
for ip in "${BLOCKED_IP4[@]}"; do test_ip_block "$ip" "v4" "ping"  "rules_on"; done
for ip in "${BLOCKED_IP6[@]}"; do test_ip_block "$ip" "v6" "$V6_PING_CMD" "rules_on"; done

test_latency "1.1.1.1" "v4" "ping"  "rules_on"
test_latency "2606:4700:4700::1111" "v6" "$V6_PING_CMD" "rules_on"

# test_throughput "IPERF_SERVER_V4" "v4" "" "rules_on"
# test_throughput "IPERF_SERVER_V6" "v6" "-6" "rules_on"

log "Done. Results written to $OUTFILE"

aggregate_results() {
    awk -F, '
    {
        key=$1 "-" $2 "-" $5
        sum[key]+=$7
        n[key]++
    }
    END {
        for (k in sum)
            print k, sum[k]/n[k]
    }' "$OUTFILE"
}

log "Aggregate results:"
aggregate_results

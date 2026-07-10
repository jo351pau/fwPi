#!/usr/bin/env bash

#!/usr/bin/env bash

run_ip_block() {
    local state=$1

    # -- IPv4 Block --
    for ip in "${BLOCKED_IP4[@]}"; do
        test_ip_block "$ip" "v4" "ping" "$state"
    done

    # -- IPv6 Block --
    for ip in "${BLOCKED_IP6[@]}"; do
            test_ip_block "$ip" "v6" "$V6_PING_CMD" "$state"
        done
}

test_ip_block() {
    local ip=$1
    local stack=$2
    local pingcmd=$3
    local state=$4

    for ((i=1;i<=REPS;i++)); do
        start=$(now_ms)
        out=$(run_ping "$pingcmd" "$ip")

        if echo "$out" | grep -qE 'bytes from|time[=<]'; then
            reachable=1
        else
            reachable=0
        fi

        end=$(now_ms)
        ms=$((end-start))
        success=0

        if [[ "$state" == "rules_on" && "$reachable" == 0 ]]; then
            success=1
        fi
        if [[ "$state" == "rules_off" && "$reachable" == 1 ]]; then
            success=1
        fi

        echo "ip_block,$stack,$ip,$i,$state,$ms,$success" >> "$OUTFILE"
    done
}
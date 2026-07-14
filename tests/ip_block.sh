#!/usr/bin/env bash

run_ip_block() {
    local state=$1

    # -- IPv4 Block --
    for ip in "${BLOCKED_IP4[@]}"; do
        test_ip_block "$ip" "v4" "$state"
    done

    # -- IPv6 Block --
    for ip in "${BLOCKED_IP6[@]}"; do
            test_ip_block "$ip" "v6" "$state"
        done
}

test_ip_block() {
    local ip=$1
    local stack=$2
    local state=$3

    for ((i=1;i<=REPS;i++)); do
        start=$(now_ms)
        out=$($RUN_PING "$stack" "$ip")

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
#!/usr/bin/env bash

run_ip_block() {
    for ip in "${BLOCKED_IP4[@]}"; do
        test_ip_block "$ip" "v4"
    done

    for ip in "${BLOCKED_IP6[@]}"; do
        test_ip_block "$ip" "v6"
    done
}

test_ip_block() {
    local ip=$1
    local stack=$2

    start=$(now_ms)
    # ping -c 1 -W 1000 3.251.50.149
    out=$(run_ping "$stack" "$ip" 2>&1)

    blocked=1
    if echo "$out" | grep -qE 'bytes from|time[=<]'; then
        blocked=0
    fi

    end=$(now_ms)
    ms=$((end-start))

    csv_write "ip_block,$stack,-,$ip,$ms,$blocked"
}
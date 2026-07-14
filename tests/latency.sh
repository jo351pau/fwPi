#!/usr/bin/env bash

# does not work because of DNS blocking via IP in nftables
test_latency() {

    local target=$1
    local stack=$2
    local state=$3

    for ((i=1; i<=REPS; i++)); do

        out=$($RUN_PING "$stack" "$target")
        ms=$(extract_time "$out")

        if [[ -z "$ms" ]]; then
            ms=-1
            success=0
        else
            success=1
        fi

        echo "latency,$stack,$target,$i,$state,$ms,$success" >> "$OUTFILE"

    done
}

run_latency() {

    local state=$1

    # Cloudflare
    test_latency "1.1.1.1" "v4" "$state"
    test_latency "2606:4700:4700::1111" "v6" "$state"

}
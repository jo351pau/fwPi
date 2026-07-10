#!/usr/bin/env bash

# This tests wether it is possible to reach a blocked domain (eg Facebook.com)
# With DNS bypass: $ dig @1.1.1.1 facebook.com -> 0.0.0.0
# Because nftables is blocking other DNS and forcing redirect via Pihole

run_dns_bypass() {
    local state=$1

    local servers=(
        "1.1.1.1"
        "8.8.8.8"
        "9.9.9.9"
    )

    local test_domain="facebook.com"

    for server in "${servers[@]}"; do

        for ((i=1;i<=REPS;i++)); do

            start=$(now_ms)
            answer=$(dig @"$server" "$test_domain" A +short +time=2 +tries=1)
            end=$(now_ms)
            ms=$((end-start))
            success=0

            if [[ "$state" == "rules_off" ]]; then
                # External DNS should work
                [[ -n "$answer" ]] && success=1
            else
                # External DNS should be intercepted by Pi-hole
                [[ "$answer" == "0.0.0.0" ]] && success=1
            fi

            echo "dns_bypass,v4,$server,$i,$state,$ms,$success" >> "$OUTFILE"
        done
    done
}
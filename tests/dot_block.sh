#!/usr/bin/env bash

test_dot() {
    local server=$1
    local stack=$2
    local state=$3

    for ((i=1; i<=REPS; i++)); do

        start=$(now_ms)

        if command -v timeout >/dev/null 2>&1; then
            out=$(timeout 5 openssl s_client -connect "${server}:853" </dev/null 2>&1)
        elif command -v gtimeout >/dev/null 2>&1; then
            out=$(gtimeout 5 openssl s_client -connect "${server}:853" </dev/null 2>&1)
        else
            # macOS fallback: rely on openssl returning after the handshake
            out=$(openssl s_client -connect "${server}:853" </dev/null 2>&1)
        fi

        end=$(now_ms)
        ms=$((end-start))

        if echo "$out" | grep -q "^CONNECTED"; then
            connected=1
        else
            connected=0
        fi

        success=0

        if [[ "$state" == "rules_off" && "$connected" == 1 ]]; then
            success=1
        fi

        if [[ "$state" == "rules_on" && "$connected" == 0 ]]; then
            success=1
        fi

        echo "dot_block,$stack,$server,$i,$state,$ms,$success" >> "$OUTFILE"

    done
}

run_dot_block() {

    local state=$1

    local ipv4_servers=(
        "1.1.1.1"
        "8.8.8.8"
        "9.9.9.9"
    )

    local ipv6_servers=(
        "2606:4700:4700::1111"
        "2001:4860:4860::8888"
        "2620:fe::fe"
    )

    for server in "${ipv4_servers[@]}"; do
        test_dot "$server" "v4" "$state"
    done

    for server in "${ipv6_servers[@]}"; do
        test_dot "$server" "v6" "$state"
    done
}
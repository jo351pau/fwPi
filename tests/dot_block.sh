#!/usr/bin/env bash

test_dot() {
    local server=$1
    local stack=$2

    start=$(now_ms)

    # macOS fallback: rely on openssl returning after the handshake
    out=$(openssl s_client -connect "${server}:853" </dev/null 2>&1)

    rc=$?

    end=$(now_ms)
    ms=$((end-start))

    blocked=0

    if [[ $rc -ne 0 ]] || ! grep -q "^CONNECTED" <<< "$out"; then
        blocked=1
    fi

    echo "dot_block,$stack,$server,$i,$ms,$blocked" >> "$OUTFILE"
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
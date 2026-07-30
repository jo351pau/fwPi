#!/usr/bin/env bash
# DoT is blocked in basemode

test_dot() {
    local server=$1
    local stack=$2

    start=$(now_ms)

    # macOS fallback: rely on openssl returning after the handshake
    out=$($TIMEOUT openssl s_client $stack -connect "${server}:853" </dev/null 2>&1)
    rc=$?

    end=$(now_ms)
    ms=$((end-start))

    #command=$"$TIMEOUT openssl s_client -connect "${server}:853" -brief"
    #log "rc = $rc"

    blocked=0
    # for openssl 124 is timeout eg expected if fw intervenes conncetion
    if [[ $rc -eq 124 ]] <<< "$out"; then
        blocked=1
    fi

    csv_write "dot_block,$stack,$server,"-",$ms,$blocked"
}

run_dot_block() {

    local ipv4_servers=(
        "1.1.1.1"
        "8.8.8.8"
        "9.9.9.9"
    )

    local ipv6_servers=(
        "[2606:4700:4700::1111]"
        "[2001:4860:4860::8888]"
        "[2620:fe::fe]"
    )

    for server in "${ipv4_servers[@]}"; do
        test_dot "$server" "-4"
    done

    for server in "${ipv6_servers[@]}"; do
        test_dot "$server" "-6"
    done
}
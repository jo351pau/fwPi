#!/usr/bin/env bash
# DoT is blocked in basemode

test_dot() {
    local server=$1
    local stack=$2

    if [[ "$stack" == "v4" ]]; then
        STACK=$"-4"
    else
        STACK=$"-6"
    fi

    start=$(now_ms)

    # macOS fallback: rely on openssl returning after the handshake
    out=$($TIMEOUT openssl s_client $STACK -host "${server}" -port 853 -brief </dev/null 2>&1)
    rc=$?

    end=$(now_ms)
    ms=$((end-start))

    # command=$"$TIMEOUT openssl s_client -connect "${server}:853" -brief"

#     echo "cmd=$TIMEOUT openssl s_client $STACK -host "${server}" -port 853 -brief"
#     echo "out=$out"
#     echo "rc=$rc"

    blocked=1
    # for openssl 124 is timeout eg expected if fw intervenes conncetion
    if [[ $rc -eq 0 ]]; then
        blocked=0
    fi

    csv_write "dot_block,$stack,$server,-,$ms,$blocked"
}

run_dot_block() {

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
        test_dot "$server" "v4"
    done

    for server in "${ipv6_servers[@]}"; do
        test_dot "$server" "v6"
    done
}
#!/usr/bin/env bash

test_doq() {
    local doq_endpoint=$1
    local url=$2
    local stack=$3

    if [[ "$stack" == "v4" ]]; then
        STACK=$"-4"
        RECORD=$"A"
    else
        STACK=$"-6"
        RECORD=$"AAAA"
    fi


    start=$(now_ms)

    # kdig -6 +quic @2606:4700:4700::1111 facebook.com AAAA
    # kdig -4 +quic @1.1.1.1 facebook.com A

    out=$(kdig $STACK +quic @$"${doq_endpoint}" +short "$url" $RECORD 2>&1)
    rc=$?

    end=$(now_ms)
    ms=$((end-start))

#     echo "cmd=kdig $STACK +quic @"${doq_endpoint}" +short "$url" $RECORD"
#     echo "out=$out"
#     echo "rc=$rc"

    blocked=1

    if [[ $rc -eq 0 ]]; then
        blocked=0
    fi

    csv_write "doq_block,$stack,$doq_endpoint,$url,$ms,$blocked"
}

run_doq_block() {

    local doq_endpoints_v4=(
        # Cloudflare:
        "1.1.1.1"
        "1.0.0.1"

        # Google:
        "8.8.8.8"
        "8.8.4.4"

        # Quad9:
        "9.9.9.9"
        "149.112.112.112"
    )

    local doq_endpoints_v6=(
        # Cloudflare:
        "[2606:4700:4700::1111]"
        "[2606:4700:4700::1001]"

        # Google:
        "[2001:4860:4860::8888]"
        "[2001:4860:4860::8844]"

        # Quad9:
        "[2620:fe::fe]"
        "[2620:fe::9]"
    )

    for domain in "${BLOCKED_DOMAINS[@]}"; do
        for doq_endpoint_v4 in "${doq_endpoints_v4[@]}"; do
            test_doq $doq_endpoint_v4 $domain "v4"
        done

        for doq_endpoint_v6 in "${doq_endpoints_v6[@]}"; do
            test_doq $doq_endpoint_v6 $domain "v6"
        done
    done
}
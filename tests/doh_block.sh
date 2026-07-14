#!/usr/bin/env bash

test_doh() {
    local url=$1
    local stack=$2
    local state=$3

    for ((i=1; i<=REPS; i++)); do

        start=$(now_ms)

        # forces curl to use adress family specified
        if [[ "$stack" == "v4" ]]; then
            CURL_IP="--ipv4"
        else
            CURL_IP="--ipv6"
        fi

        out=$(curl $CURL_IP -sS \
            -H 'accept: application/dns-json' \
            --max-time 5 \
            "${url}?name=example.com&type=A" \
            2>&1)

        rc=$?

        end=$(now_ms)
        ms=$((end-start))

        if [[ $rc -eq 0 ]] && echo "$out" | grep -q '"Answer"'; then
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

        csv_write "doh_block,$stack,$url,$i,$state,$ms,$success"

    done
}

run_doh_block() {

    local state=$1

    local ipv4_servers=(
        "https://cloudflare-dns.com/dns-query"
        "https://dns.google/resolve"
        "https://dns.quad9.net/dns-query"
    )

    # Same endpoints; IPv6 is selected automatically if available.
    local ipv6_servers=(
        "https://cloudflare-dns.com/dns-query"
        "https://dns.google/resolve"
        "https://dns.quad9.net/dns-query"
    )

    for server in "${ipv4_servers[@]}"; do
        test_doh "$server" "v4" "$state"
    done

    for server in "${ipv6_servers[@]}"; do
        test_doh "$server" "v6" "$state"
    done
}
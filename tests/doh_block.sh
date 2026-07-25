#!/usr/bin/env bash

test_doh() {
    local url="$1"
    local domain="$2"
    local stack="$3"
    local rtype="$4"

    local start
    local end
    local out
    local rc
    local ms
    local blocked
    local CURL_IP

    if [[ "$stack" == "v4" ]]; then
        CURL_IP="--ipv4"
    else
        CURL_IP="--ipv6"
    fi

    start=$(now_ms)

    out=$(curl $CURL_IP -sS \
        -H 'accept: application/dns-json' \
        --max-time 4 \
        "${url}?name=${domain}&type=${rtype}" \
        2>&1)

    rc=$?

    end=$(now_ms)
    ms=$((end-start))

    blocked=0

    if [[ $rc -ne 0 ]] || ! grep -q '"Answer"' <<< "$out"; then
        blocked=1
    fi

    echo "doh_block,$stack,$domain,$rtype,$i,$ms,$blocked" >> "$OUTFILE"
}

run_doh() {

    local state=$1

    local ipv4_servers=(
        "https://cloudflare-dns.com/dns-query"
        "https://dns.google/resolve"
        "https://dns.quad9.net/dns-query"
    )

    for server in "${servers[@]}"; do
        for domain in "${BLOCKED_DOMAINS[@]}"; do

            test_doh "$server" "$domain" "v4" "A"
            test_doh "$server" "$domain" "v6" "AAAA"

        done
    done

}
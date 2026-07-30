#!/usr/bin/env bash

test_doh() {
    local server="$1"
    local domain="$2"
    local stack="$3"

    if [[ "$stack" == "v4" ]]; then
        STACK=$"--ipv4"
        RECORD=$"A"
    else
        STACK=$"--ipv6"
        RECORD=$"AAAA"
    fi

    start=$(now_ms)

    # /opt/homebrew/opt/curl/bin/curl --ipv4 -sS -H 'accept: application/dns-json' --max-time 4 ""https://cloudflare-dns.com/dns-query"?name=facebook.com&type=A"
    out=$($CURL $STACK -sS \
        -H 'accept: application/dns-json' \
        --max-time 4 \
        "${server}?name=${domain}&type=$RECORD" \
        2>&1)

    rc=$?

    end=$(now_ms)
    ms=$((end-start))

    blocked=0

    # rc 28 is timeout and should happen in case of failure due to tc or test_doh
    # there are some other cases where rc=35 or rc=0 but instead of "answer" section I get "authority" section
    if [[ $rc -eq 28 ]] <<< "$out"; then
        blocked=1
    fi


    csv_write "doh_block,$stack,$server,$domain,$ms,$blocked"

}

run_doh_block() {
    local ipv4_servers=(
        "https://cloudflare-dns.com/dns-query"
        "https://dns.google/resolve"
        "https://dns.quad9.net/dns-query"
    )

    for server in "${ipv4_servers[@]}"; do
        for domain in "${BLOCKED_DOMAINS[@]}"; do
            test_doh "$server" "$domain" "v4"
            test_doh "$server" "$domain" "v6"
        done
    done

}
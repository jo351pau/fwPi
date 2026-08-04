#!/usr/bin/env bash

test_quic() {
    local url=$1
    local stack=$2

    # forces curl to use adress family specified
    if [[ "$stack" == "v4" ]]; then
        STACK=$"--ipv4"
    else
        STACK=$"--ipv6"
    fi

    start=$(now_ms)

    out=$($CURL $STACK --http3 -I -s "$url" 2>&1)
    rc=$?

    end=$(now_ms)
    ms=$((end-start))

    blocked=1

    if [[ $rc -eq 0 ]] && grep -q "^HTTP/3" <<< "$out"; then
        blocked=0
    fi

    csv_write "quic_block,$stack,-,$url,$ms,$blocked"
}

run_quic_block() {
    # sites are likely to support quic
    local sites=(
        "https://cloudflare.com"
        "https://google.com"
    )

    for site in "${sites[@]}"; do
        test_quic "$site" "v4"
        test_quic "$site" "v6"
    done
}
#!/usr/bin/env bash

test_quic() {

    local url=$1
    local stack=$2

    # forces curl to use adress family specified
    if [[ "$stack" == "v4" ]]; then
        CURL_IP="--ipv4"
    else
        CURL_IP="--ipv6"
    fi

    start=$(now_ms)

    out=$($CURL --http3 -I -s "$url" 2>&1)

    end=$(now_ms)
    ms=$((end-start))

    blocked=1

    if echo "$out" | grep -q "^HTTP/3"; then
        blocked=0
    fi

    echo "quic_block,$stack,$url,$i,,$ms,$blocked" >> "$OUTFILE"

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
#!/usr/bin/env bash

test_quic() {

    local url=$1
    local stack=$2
    local state=$3

    for ((i=1; i<=REPS; i++)); do

        # forces curl to use adress family specified
        if [[ "$stack" == "v4" ]]; then
            CURL_IP="--ipv4"
        else
            CURL_IP="--ipv6"
        fi

        start=$(now_ms)

        if command -v timeout >/dev/null 2>&1; then
            out=$(timeout 5 $CURL $CURL_IP --http3 -I -s "$url" 2>&1)
        elif command -v gtimeout >/dev/null 2>&1; then
            out=$(gtimeout 5 $CURL $CURL_IP --http3 -I -s "$url" 2>&1)
        else
            out=$($CURL --http3 -I -s "$url" 2>&1)
        fi

        end=$(now_ms)
        ms=$((end-start))

        if echo "$out" | grep -q "^HTTP/3"; then
            quic=1
        else
            quic=0
        fi
        success=0

        if [[ "$state" == "rules_off" && "$quic" == 1 ]]; then
            success=1
        fi

        if [[ "$state" == "rules_on" && "$quic" == 0 ]]; then
            success=1
        fi

        echo "quic_block,$stack,$url,$i,$state,$ms,$success" >> "$OUTFILE"
    done
}

run_quic_block() {
    local state=$1
    local sites=(
        "https://cloudflare.com"
        "https://google.com"
    )

    for site in "${sites[@]}"; do
        test_ech "$site" "v4" "$state"
        test_ech "$site" "v6" "$state"
    done
}
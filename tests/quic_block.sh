#!/usr/bin/env bash
#
# CURL="$(command -v curl)"
#
# If this does not work: $ brew install curl
# /opt/homebrew/opt/curl/bin/curl --http3 https://cloudflare.com
CURL="/opt/homebrew/opt/curl/bin/curl" # if standard curl --http3 does not work

test_quic() {

    local url=$1
    local stack=$2
    local state=$3

    for ((i=1; i<=REPS; i++)); do

        start=$(now_ms)

        if command -v timeout >/dev/null 2>&1; then
            out=$(timeout 5 $CURL --http3 -I -s "$url" 2>&1)
        elif command -v gtimeout >/dev/null 2>&1; then
            out=$(gtimeout 5 $CURL --http3 -I -s "$url" 2>&1)
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
    test_quic "https://cloudflare.com" "v4" "$state"
    test_quic "https://google.com"      "v4" "$state"
}
#!/usr/bin/env bash
#
# Tests Pi-hole blocklist and DNS interception.
#
# CSV:
#   test_type,server,target,record_type,trial,result_ms,blocked
#
# blocked:
#   0 = not blocked
#   1 = blocked
#

# ------------------------------------------------------------
# DNS test
# ------------------------------------------------------------

test_dns() {
    local test_type="$1"
    local server="$2"
    local domain="$3"
    local stack="$4"

    if [[ "$stack" == "v4" ]]; then
        STACK=$"-4"
        RECORD=$"A"
    else
        STACK=$"-6"
        RECORD=$"AAAA"
    fi

    start=$(now_ms)

    # dig -4 +short +time=2 +tries=1 facebook.com A @1.1.1.1
    # dig -4 +short +time=2 +tries=1 facebook.com A @192.168.50.1
    out=$(dig $STACK +short +time=2 +tries=1 "$domain" $RECORD "@$server" | tr -d '\r')

    end=$(now_ms)
    ms=$((end - start))

    blocked=0

    case "$stack" in
        v4)
            [[ "$out" == "0.0.0.0" ]] && blocked=1
            ;;
        v6)
            [[ "$out" == "::" ]] && blocked=1
            ;;
    esac

    csv_write "$test_type,$stack,$server,$domain,$ms,$blocked"

}


# ------------------------------------------------------------
# Pi-hole interception
# ------------------------------------------------------------

run_dns_interception() {
    local server="$GATEWAY_V4"

    for domain in "${BLOCKED_DOMAINS[@]}"; do
        test_dns "dns_interception" "$server" "$domain" v4
        test_dns "dns_interception" "$server" "$domain" v6
    done
}


# ------------------------------------------------------------
# DNS bypass
# ------------------------------------------------------------

run_dns_bypass() {
    local servers=(
        "1.1.1.1"
        "8.8.8.8"
        "9.9.9.9"
    )

    for server in "${servers[@]}"; do
        for domain in "${BLOCKED_DOMAINS[@]}"; do
            test_dns "dns_bypass" "$server" "$domain" v4
            test_dns "dns_bypass" "$server" "$domain" v6
        done
    done
}
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
    local rtype="$4"

    local start
    local end
    local result
    local ms
    local blocked

    for ((i=1; i<=REPS; i++)); do
        start=$(now_ms)

        result=$(
            dig +short \
                +time=2 \
                +tries=1 \
                "$domain" \
                "$rtype" \
                "@$server" |
            tr -d '\r'
        )

        end=$(now_ms)
        ms=$((end - start))

        blocked=0

        case "$rtype" in
            A)
                [[ "$result" == "0.0.0.0" ]] && blocked=1
                ;;
            AAAA)
                [[ "$result" == "::" ]] && blocked=1
                ;;
        esac

        echo \
            "$test_type,$server,$domain,$rtype,$i,$ms,$blocked" \
            >> "$OUTFILE"
    done
}


# ------------------------------------------------------------
# Pi-hole interception
# ------------------------------------------------------------

run_dns_interception() {
    local server="$PIHOLE_DNS"

    for domain in "${BLOCKED_DOMAINS[@]}"; do
        test_dns "dns_interception" "$server" "$domain" A
        test_dns "dns_interception" "$server" "$domain" AAAA
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
            test_dns "dns_bypass" "$server" "$domain" A
            test_dns "dns_bypass" "$server" "$domain" AAAA
        done
    done
}
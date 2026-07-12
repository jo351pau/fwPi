#!/usr/bin/env bash

test_dns() {
    local domain=$1
    local rtype=$2
    local stack=$3
    local expect=$4
    local state=$5

    for ((i=1;i<=REPS;i++)); do
        start=$(now_ms)
        result=$(dig +short +time=2 +tries=1 "$rtype" "$domain" | tr -d '\r')
        end=$(now_ms)
        ms=$((end-start))
        blocked=0

        case "$rtype" in
            A)
                [[ "$result" == "0.0.0.0" ]] && blocked=1
                ;;
            AAAA)
                [[ "$result" == "::" ]] && blocked=1
                ;;
        esac

        success=0

        # expect=1 means domain should resolve
        # expect=0 means domain should be Pi-hole blocked
        if [[ "$expect" == "1" && "$blocked" == "0" ]]; then
            success=1
        fi

        if [[ "$expect" == "0" && "$blocked" == "1" ]]; then
            success=1
        fi

        echo "dns_${rtype},${stack},${domain},${i},${state},${ms},${success}" >> "$OUTFILE"
    done
}

run_dns_interception() {

    local state=$1

    if [[ "$state" == "rules_off" ]]; then
        expected_blocked=1
    else
        expected_blocked=0
    fi

    for d in "${BLOCKED_DOMAINS[@]}"; do
        test_dns "$d" "A" "v4" "$expected_blocked" "$state"
        test_dns "$d" "AAAA" "v6" "$expected_blocked" "$state"
    done

    for d in "${ALLOWED_DOMAINS[@]}"; do
        test_dns "$d" "A" "v4" 1 "$state"
        test_dns "$d" "AAAA" "v6" 1 "$state"
    done
}
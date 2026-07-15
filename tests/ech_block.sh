#!/usr/bin/env bash
# ! TEstbed does not have DPI capabilities necessary for breaking ECH traffic !

test_ech() {
    local url=$1
    local stack=$2
    local state=$3

    for ((i=1; i<=REPS; i++)); do

        start=$(now_ms)

        curl_cmd=(curl -sS --max-time 5)

        [[ "$stack" == "v4" ]] && curl_cmd+=(--ipv4)
        [[ "$stack" == "v6" ]] && curl_cmd+=(--ipv6)

        "${curl_cmd[@]}" "$url" >/dev/null
        rc=$?

        end=$(now_ms)
        ms=$((end-start))

        connected=0
        [[ $rc -eq 0 ]] && connected=1

        success=0

        if [[ "$state" == "rules_off" && "$connected" == 1 ]]; then
            success=1
        fi

        # Your firewall can N O T block ECH specifically,
        # so connectivity should remain possible.
        if [[ "$state" == "rules_on" && "$connected" == 1 ]]; then
            success=1
        fi

        csv_write "ech,$stack,$url,$i,$state,$ms,$success"
    done
}

run_ech() {

    local state=$1

    local sites=(
        "https://cloudflare-ech.com/"
    )

    for site in "${sites[@]}"; do
        test_ech "$site" "v4" "$state"
        test_ech "$site" "v6" "$state"
    done
}
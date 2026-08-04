#!/usr/bin/env bash

log() {
    echo "$(date '+%H:%M:%S') $*"
}

now_ms() {
    python3 -c 'import time; print(int(time.time()*1000))'
}

extract_time() {
    echo "$1" |
    sed -nE 's/.*time[=<]([0-9.]+).*/\1/p' |
    head -n1
}

run_ping_mac() {
    local family=$1
    local target=$2
    local count=$3

    if [[ "$family" == "v6" ]]; then
        ping6 -c "$count" "$target" 2>/dev/null # On Linux add -W 1: does not exist for ping6 :(
    else
        ping -c "$count" -W 1000 "$target" 2>/dev/null # On linux -W 1
    fi
}

run_ping_linux() {
    local family=$1
    local target=$2
    local count=$3

    if [[ "$family" == "v6" ]]; then
        ping -6 -c "$count" -W 1 "$target" 2>/dev/null
    else
        ping -c "$count" -W 1 "$target" 2>/dev/null
    fi
}

run_ping() {
    local family=$1
    local target=$2
    local count=${3:-1}

    if [[ "$OS" == "macos" ]]; then
        run_ping_mac "$family" "$target" "$count"
    else
        run_ping_linux "$family" "$target" "$count"
    fi
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing dependency: $1"
        exit 1
    }
}

csv_write() {
    if [[ $# -eq 1 ]]; then
             printf '%s\n' "$CURRENT_MODE,$1" >> "$OUTFILE" # for all accuracy tests
         else
             local file="$1"
             shift
             printf '%s\n' "$CURRENT_MODE,$1" >> "$file"
         fi
}



aggregate_results() {
    local summary="${OUTFILE%.csv}_summary.csv"

    printf '%s\n' \
        "mode,avg_latency_ms,block_rate_percent,total_tests,blocked_tests" \
        > "$summary"

    awk -F, '
    NR == 1 { next }

    {
        mode = $1

        latency_sum[mode] += $5
        total[mode]++

        if ($6 == 1)
            blocked[mode]++
    }

    END {
        for (mode in total) {
            printf "%s,%.2f,%.2f,%d,%d\n",
                mode,
                    latency_sum[mode] / total[mode],
                    100 * blocked[mode] / total[mode],
                    total[mode],
                    blocked[mode]
        }
    }
    ' "$OUTFILE" >> "$summary"

    echo "Summary written to: $summary"
}
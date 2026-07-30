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

    if [[ "$family" == "v6" ]]; then
        ping6 -c 1 "$target" 2>/dev/null # On Linux add -W 1: does not exist for ping6 :(
    else
        ping -c 1 -W 1000 "$target" 2>/dev/null # On linux -W 1
    fi
}

run_ping_linux() {
    local family=$1
    local target=$2

    if [[ "$family" == "v6" ]]; then
        "$V6_PING_CMD" -c 1 -W 1 "$target" 2>/dev/null
    else
        ping -c 1 -W 1 "$target" 2>/dev/null
    fi
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing dependency: $1"
        exit 1
    }
}

csv_write() {
    printf '%s,%s\n' "$CURRENT_MODE,$*" >> "$OUTFILE"
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
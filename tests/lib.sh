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
        $V6_PING_CMD -c 1 "$target" 2>/dev/null # On Linux add -W 1: does not exist for ping6 :(
    else
        ping -c 1 -W 1000 "$target" 2>/dev/null # On linux -W 1
    fi
}

run_ping_linux() {
    local family=$1
    local target=$2

    if [[ "$family" == "v6" ]]; then
        $V6_PING_CMD -c 1 -W 1 "$target" 2>/dev/null
    else
        ping -c 1 -W 1 "$target" 2>/dev/null
    fi
}

csv_write() {
    echo "$*" >> "$OUTFILE"
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing dependency: $1"
        exit 1
    }
}

aggregate_results() {
    awk -F, '
    {
        key=$1 "-" $2 "-" $5
        sum[key]+=$7
        n[key]++
    }
    END {
        for (k in sum)
            print k, sum[k]/n[k]
    }' "$OUTFILE"
}
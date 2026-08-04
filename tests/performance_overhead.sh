#!/usr/bin/env bash
#
# performance_overhead/performance_overhead.sh
#
# Measures throughput (iperf3), CPU utilization (mpstat on the Pi), and RTT
# (ping) concurrently so all three numbers describe the same load window.
# Called once per mode by run.sh, which handles mode-switching and prompting.
#
# Remote prerequisite: sudo apt install sysstat
# Local prerequisite:  ssh-add ~/.ssh/id_ed25519   (key must be loaded in the
#                       agent, since sampling runs in the background with no
#                       tty available to prompt for a passphrase)
#
# Usage (called from run.sh): run_performance_overhead

set -uo pipefail

# ---- CONFIG ------------------------------------------------------------
DURATION=30                 # seconds per iperf3 run
RUNS=1                       # repetitions per mode, for mean/std dev
PING_COUNT=30                 # pings sent per run, roughly matching DURATION
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=5)
MAX_WAIT=40                   # max seconds to wait for background mpstat to exit
IPERF_SERVER=""
GATEWAY=""
STACKS=("v4" "v6")

# ---- HELPERS -------------------------------------------------------------

check_ssh() {
    if ! ssh "${SSH_OPTS[@]}" "$PI_HOST" true; then
        echo "  [ERROR] SSH authentication failed. Check that your key is installed and loaded:" >&2
        echo "          ssh-copy-id $PI_HOST" >&2
        echo "          ssh-add ~/.ssh/id_ed25519" >&2
        return 1
    fi
}

# resolve the right target + iperf3/ping flags for a given stack
stack_target() {
    local stack="$1"
    case "$stack" in
        v4)
            IPERF_SERVER="$IPERF_SERVER_V4"
            IPERF_FLAG="-4"
            GATEWAY="$GATEWAY_V4"
            ;;
        v6)
            IPERF_SERVER="$IPERF_SERVER_V6"
            IPERF_FLAG="-6"
            GATEWAY="$GATEWAY_V6"
            ;;
        *) echo "  [ERROR] unknown stack: $stack" >&2; return 1 ;;
    esac
}

# One iperf3 run: writes raw JSON to $IPERF_LOG and a summary row
# to $IPERF_RESULT. Echoes the achieved Mbit/s so callers can log it.
run_iperf() {
    local run_num="$1" stack="$2"
    local json

    # iperf3 -c 192.168.50.115 -p 5201 -t 30
    json=$(iperf3 -c "$IPERF_SERVER" -p "$IPERF_PORT" -t "$DURATION" -J)
    status=$?

    if [ $status -ne 0 ]; then
        echo "iperf3 failed:"
        return 1
    fi


    local mbits retrans ts
    mbits=$(echo "$json" | jq '.end.sum_sent.bits_per_second / 1000000')
    mbits=$(LC_NUMERIC=C printf "%.2f" "$mbits")
    retrans=$(echo "$json" | jq '.end.sum_sent.retransmits')
    retrans=${retrans:-0}
    ts=$(now_ms)

    csv_write "$IPERF_RESULT" "${run_num},${stack},${mbits},${retrans},${ts}"
}

run_rtt() {
    local run_num="$1" stack="$2"
    local out avg_rtt ts


    out=$(run_ping "$stack" "$GATEWAY" "$PING_COUNT") || {
        echo "  [WARN] ping run $run_num failed" | tee -a "$RTT_LOG"
        return 1
    }

    case "$OS" in
        linux)
            avg_rtt=$(grep '^rtt' <<<"$out" | cut -d= -f2 | awk -F/ '{gsub(/ /,""); print $2}')
            ;;
        macos)
            avg_rtt=$(grep '^round-trip' <<<"$out" | cut -d= -f2 | awk -F/ '{gsub(/ /,""); print $2}')
            ;;
    esac

    ts=$(now_ms)

    csv_write "$RTT_RESULT" ""rtt",${run_num},${stack},${avg_rtt},${ts}"
}

# Background CPU sampling on the Pi via mpstat, run roughly the same duration as one iperf3 transfer.
start_cpu_sampling() {
    ssh "${SSH_OPTS[@]}" -T -n "$PI_HOST" \
        "mpstat 1 $((DURATION + 2)) </dev/null" >> "$MPSTAT_LOG" 2>&1 &
    echo $!
}

wait_for_sampling() {
    local sample_pid="$1"
    local waited=0

    while kill -0 "$sample_pid" 2>/dev/null; do
        sleep 1
        waited=$((waited + 1))
        if (( waited >= MAX_WAIT )); then
            echo "  [WARN] ssh sampling did not exit within ${MAX_WAIT}s, killing it"
            kill "$sample_pid" 2>/dev/null
            break
        fi
    done
    wait "$sample_pid" 2>/dev/null
}

# ---- MAIN -------------------------------------

run_performance_overhead() {
    log "----------------------------------------"
    log "Performance overhead"
    log "----------------------------------------"


    echo "run,stack,throughput_mbits,retransmits,timestamp" > "$IPERF_RESULT"

    check_ssh || return 1

    for stack in "${STACKS[@]}"; do
        for run in $(seq 1 "$RUNS"); do
            local sample_pid

            stack_target "$stack" # sets IPERF_SERVER, GATEWAY and IPERF_FLAG based on stack var

            sample_pid=$(start_cpu_sampling)

            sleep 1  # let mpstat spin up before load starts

            # reflects latency under load rather than an idle link
            run_rtt "$run" "$stack" &
            local rtt_pid=$!

            run_iperf "$run" "$stack" || true

            wait "$rtt_pid" 2>/dev/null
            wait_for_sampling "$sample_pid"

            sleep 2   # brief pause between runs to avoid overlapping TCP state
        done
    done
}
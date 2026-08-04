#!/usr/bin/env bash
#
# Throttling accuracy: throughput + latency across configured tc rates
#
# Results: throttling_latency.txt throttling_throughput.txt

rates=("64kbit" "256kbit" "1mbit")

run_baseline(){
  echo "=== Baseline (base mode, no throttling) ===" >> "$THROUGHPUT_LOG" "$LATENCY_LOG"

  iperf3 -c "$IPERF_SERVER_V4" -p "$IPERF_PORT" -t 30 >> "$THROUGHPUT_LOG"
  run_ping "v4" "$GATEWAY_V4" "$PING_COUNT" >> "$LATENCY_LOG"
}

run_rate_sweep(){
  for rate in "${rates[@]}"; do
    echo
    echo "=== tc mode @ $rate ==="
    read -rp "Run 'fw-censor tc $rate' on the Pi, then press Enter..."

    {
      echo "=== tc @ $rate ==="
      iperf3 -c "$IPERF_SERVER_V4" -p "$IPERF_PORT" -t 30
    } >> "$THROUGHPUT_LOG"

    {
      echo "=== tc @ $rate ==="
      run_ping "v4" "$GATEWAY_V4" "$PING_COUNT"
    } >> "$LATENCY_LOG"

    echo "Finished: $rate"
  done
}

run_throttling_accuracy() {
    local mode="$1"
    log "----------------------------------------"
    log "Throttling accuracy"
    log "----------------------------------------"

    case "$mode" in
       base) run_baseline ;;
       td) ;; # do nothing
       tc) run_rate_sweep ;;
    esac
}

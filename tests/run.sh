#!/usr/bin/env bash
#
# run.sh
#
# Master test runner for fw-censor.
#
# Test classes:
#   1. blocking_accuracy
#   2. bypass_resistance
#   3. performance_overhead
#   4. throttling_accuracy
#
# Each test class can be run against one or more fw-censor modes:
#   base, td, tc
#
# Usage:
#   ./run.sh
#
# Results:
#   ./results/...
#

set -uo pipefail

source "./config.sh"
source "$TEST_DIR/lib.sh"
source "$TEST_DIR/import_lists.sh"

# Blocking accuracy
source "$TEST_DIR/blocking_accuracy/ip_block.sh"
source "$TEST_DIR/blocking_accuracy/dot_block.sh"
source "$TEST_DIR/blocking_accuracy/doq_block.sh"
source "$TEST_DIR/blocking_accuracy/quic_block.sh"
source "$TEST_DIR/blocking_accuracy/dns_test.sh"
source "$TEST_DIR/blocking_accuracy/doh_block.sh"
source "$TEST_DIR/blocking_accuracy/run_blocking_accuracy.sh"

# Performance overhead
source "$TEST_DIR/performance_overhead.sh"

# throttling accuracy
source "$TEST_DIR/throttling_accuracy.sh"


# ---------------------------------------------------------------------------
# Mode handling and testing all
# ---------------------------------------------------------------------------

run_mode() {
    local mode="$1"
    CURRENT_MODE="$mode"

    read -rp "Set fw-censor to '$mode', then press Enter..."

    echo
    echo "========================================"
    echo " Testing fw-censor mode: $mode"
    echo "========================================"
    echo

    # run_blocking_accuracy
    run_performance_overhead
    run_throttling_accuracy "$mode"

    log "Finished tests for mode: $mode"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    import_lists
    # rm -rf "$TEST_DIR"/results/* # deletes prior results

    read -rp "Start iperf3 on Client 2 'iperf3 -s -p 5201', then press Enter..."
    # Full experiment.
    run_mode base
    run_mode td
    run_mode tc

    aggregate_results

    log "All test completed."
}

main "$@"
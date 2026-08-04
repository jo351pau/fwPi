#!/usr/bin/env bash

# OUTFILE="results/results_$(date +%Y%m%d_%H%M%S).csv"
RESULTS_DIR="/Users/johannapauler/Desktop/fwPi/tests/results"

OUTFILE="$RESULTS_DIR/test_results.csv"
IPERF_RESULT="$RESULTS_DIR/0_iperf_result.csv"
RTT_RESULT="$RESULTS_DIR/0_rtt_result.csv"
IPERF_LOG="$RESULTS_DIR/0_iperf_result.txt"
MPSTAT_LOG="$RESULTS_DIR/0_mpstat_result.txt"
RTT_LOG="$RESULTS_DIR/0_rtt_result.txt"
THROUGHPUT_LOG="$RESULTS_DIR/0_throttling_throughput.txt"
LATENCY_LOG="$RESULTS_DIR/0_throttling_latency.txt"

CURRENT_MODE=""

BLOCKED_DOMAINS=()
ALLOWED_DOMAINS=()
BLOCKED_IP4=()
BLOCKED_IP6=()

OS="macos"
GATEWAY_V4="192.168.50.1" # PIHOLE_DNS_V4
GATEWAY_V6="2a06:d1c1:ee:1::1" # PIHOLE_DNS_V6
PI_HOST="jp@$GATEWAY_V4"
IPERF_PORT=5201
PING_COUNT=30
IPERF_SERVER_V4="89.144.212.166" # Client 2
IPERF_SERVER_V6="2001:4bb8:13a:adb8:dfaf:4bce:f4a7:af0c" # Client 2

BASE_DIR="/Users/johannapauler/Desktop/fwPi/config"
TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

BLOCKLIST="$BASE_DIR/pihole/my_blocklist.txt"
ALLOWLIST="$BASE_DIR/pihole/my_allowlist.txt"

DENY_IPV4="$BASE_DIR/nftables/nft_sets/deny_ipv4.txt"
DENY_IPV6="$BASE_DIR/nftables/nft_sets/deny_ipv6.txt"

# CURL="$(command -v curl)" # On Linux Client
# On MacOS for QUIC: $ brew install curl
# Find path (usually at /opt/homebrew/opt/curl/bin/curl)
CURL="/opt/homebrew/opt/curl/bin/curl"

# for MacOS: brew install coreutils
TIMEOUT="gtimeout 3"
# TIMEOUT="timeout 5"

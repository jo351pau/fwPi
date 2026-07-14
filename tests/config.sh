#!/usr/bin/env bash

# OUTFILE="results/results_$(date +%Y%m%d_%H%M%S).csv"
OUTFILE="results/results.csv"

REPS=1                 # repetitions per test for averaging

BLOCKED_DOMAINS=()
ALLOWED_DOMAINS=()
BLOCKED_IP4=()
BLOCKED_IP6=()

BASE_DIR="/Users/johannapauler/Desktop/fwPi/config"

BLOCKLIST="$BASE_DIR/my_blocklist.txt"
ALLOWLIST="$BASE_DIR/my_allowlist.txt"

DENY_IPV4="$BASE_DIR/deny_ipv4.txt"
DENY_IPV6="$BASE_DIR/deny_ipv6.txt"

V6_PING_CMD="ping6" # On Linux usually "ping -6"

# RUN_PING=run_ping_linux # On Linux Client
RUN_PING="run_ping_mac" # On MacOS Client

# CURL="$(command -v curl)" # On Linux Client
# On MacOS for QUIC: $ brew install curl
# Find path (usually at /opt/homebrew/opt/curl/bin/curl)
CURL="/opt/homebrew/opt/curl/bin/curl"


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

V4_PING_CMD=ping
V6_PING_CMD=ping6

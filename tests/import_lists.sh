#!/usr/bin/env bash

import_lists() {

    # --- Domains ---
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        [[ -n "$line" ]] && BLOCKED_DOMAINS+=("$line")
    done < "$BLOCKLIST"

    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        [[ -n "$line" ]] && ALLOWED_DOMAINS+=("$line")
    done < "$ALLOWLIST"

    # --- IPv4 ---
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | sed 's/,//' | xargs)

        if [[ "$line" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            BLOCKED_IP4+=("$line")
        fi
    done < "$DENY_IPV4"

    # --- IPv6 ---
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | sed 's/,//' | xargs)

        if [[ "$line" =~ : ]]; then
            BLOCKED_IP6+=("$line")
        fi
    done < "$DENY_IPV6"
}
#!/bin/bash
# /usr/local/bin/fw-censor
# CLI to switch censorship filtering on and off
# Usage:
#   fw-censor enable   — activate censorship rules
#   fw-censor disable  — deactivate censorship rules
#   fw-censor status   — show current mode and rule counters
#   fw-censor reload   — reload blocklists from disk (censorship mode only)

set -euo pipefail

NFT="/etc/nftables.conf"
STATUS_FILE="/run/fw-censor.mode"   # tracks current mode across calls
TABLE="inet filter"
CHAIN_FWD="forward"
CHAIN_CEN="censorship"
JUMP_COMMENT="censorship-jump"      # used to find and delete the jump rule

#####################
# helper
################

is_enabled() {
    # check if the jump rule exists in forward chain
    nft list chain $TABLE $CHAIN_FWD 2>/dev/null \
        | grep -q "$JUMP_COMMENT"
}

insert_jump() {
    # insert jump to censorship chain as first rule in forward chain
    # must be before the general LAN->WAN accept rule
    nft insert rule $TABLE $CHAIN_FWD \
        jump $CHAIN_CEN \
        comment \"$JUMP_COMMENT\"
}

remove_jump() {
    # find the handle of the jump rule and delete it
    local handle
    handle=$(nft -a list chain $TABLE $CHAIN_FWD \
        | grep "$JUMP_COMMENT" \
        | grep -oP 'handle \K[0-9]+')

    if [[ -n "$handle" ]]; then
        nft delete rule $TABLE $CHAIN_FWD handle "$handle"
    fi
}

flush_censorship_chain() {
    nft flush chain $TABLE $CHAIN_CEN
}

####################
# commands
#####################

cmd_enable() {
    if is_enabled; then
        echo "Censorship mode already active"
        exit 0
    fi

    # echo "Loading censorship rules..."

    echo "Inserting forward chain jump..."
    insert_jump

    echo "active" > "$STATUS_FILE"
    echo "Censorship mode enabled"
    cmd_status
}

cmd_disable() {
    if ! is_enabled; then
        echo "Censorship mode already inactive"
        exit 0
    fi

    echo "Removing forward chain jump..."
    remove_jump

    echo "Flushing censorship rules..."
    flush_censorship_chain

    echo "inactive" > "$STATUS_FILE"
    echo "Censorship mode disabled — base firewall still active"
    cmd_status
}

cmd_status() {
    echo ""
    echo "=== fw-censor status ==="
    if is_enabled; then
        echo "Mode: CENSORSHIP ACTIVE"
    else
        echo "Mode: passthrough (base firewall only)"
    fi

    echo ""
    echo "--- forward chain ---"
    nft list chain $TABLE $CHAIN_FWD

    echo ""
    echo "--- censorship chain rule counters ---"
    nft list chain $TABLE $CHAIN_CEN
}

cmd_reload() {
    if ! is_enabled; then
        echo "Censorship mode not active — nothing to reload"
        exit 1
    fi

    echo "Reloading blocklists from disk..."

    # flush and reload sets
    nft flush set $TABLE deny_ipv4
    nft flush set $TABLE deny_ipv6
    nft flush set $TABLE deny_ipv4_dns
    nft flush set $TABLE deny_ipv6_dns

    # reload base config which includes set definitions with files
    nft -f "$BASE_NFT"

    # reload censorship rules
    # load_censorship_rules
    insert_jump

    echo "Reload complete"
    cmd_status
}

######################
# entrypoint
#######################

case "${1:-}" in
    enable)   cmd_enable   ;;
    disable)  cmd_disable  ;;
    status)   cmd_status   ;;
    reload)   cmd_reload   ;;
    *)
        echo "Usage: fw-censor {enable|disable|status|reload}"
        echo ""
        echo "  enable - activate censorship filtering"
        echo "  disable - deactivate censorship filtering"
        echo "  status - show current mode and counters"
        echo "  reload - reload blocklists from disk"
        exit 1
        ;;
esac
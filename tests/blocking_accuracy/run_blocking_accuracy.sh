#!/usr/bin/env bash

run_blocking_accuracy() {
    log "----------------------------------------"
    log "Blocking accuracy"
    log "----------------------------------------"

    echo ""
    echo "test_type,stack,server,domain,ms,blocked" >> "$OUTFILE"

    run_ip_block
    log "Done -> IP blocking"

    run_dot_block
    log "Done -> DNS-over-TLS blocking"

    run_doq_block
    log "Done -> DNS-over-QUIC blocking"

    run_quic_block
    log "Done -> QUIC blocking"

    run_dns_interception
    log "Done -> DNS interception"

    run_dns_bypass
    log "Done -> DNS bypass resistance"

    run_doh_block
    log "Done -> DNS-over-HTTPS blocking"
}
# fwPi

# !!! This is in no way finished !!!

### Missing:
- Dpi/SNI
- Separate basic nftables fw from blocking fw
- (Throughput testing (iperf3))
- Traffic throttling -> should be easy
- Cli maybe??

1. Measure performance with blocking mechanisms off
2. Implement IPv6 tests for DoT and DoQ (why did I forget about those??)
3. Up the REPS counter to average data
4. Test DoH (regardless of wether I manage to implement a SNI inspection based filter
   this could be interesting)
5. Figure out what to do with those annoyingly slow timeouts

Download rasp Imager and prepare micro SD with Raspian Trixie
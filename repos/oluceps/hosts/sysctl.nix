_: {
  boot = {
    kernel.sysctl = {
      "kernel.panic" = 10;
      "kernel.sysrq" = 1;
      # max read buffer
      # max write buffer
      "fs.file-max" = 6553560;
      # default read buffer
      "net.core.rmem_default" = 65536;
      # default write buffer
      "net.core.wmem_default" = 65536;
      "net.core.netdev_budget" = 600;
      # max processor input queue
      #"net.core.netdev_max_backlog" = 4096;
      # max backlog
      #
      #
      "net.ipv4.conf.all.arp_accept" = 1;

      "net.ipv6.conf.all.accept_ra" = 2;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.rp_filter" = 0;

      # Ignore ICMP broadcasts to avoid participating in Smurf attacks
      "net.ipv4.icmp_echo_ignore_broadcasts" = 0;
      # Ignore bad ICMP errors
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse-path filter for spoof protection
      # SYN flood protection
      "net.ipv4.tcp_syncookies" = 0;
      "net.ipv4.tcp_syn_retries" = 2;
      # Do not accept ICMP redirects (prevent MITM attacks)
      "net.ipv4.conf.all.secure_redirects" = 1;
      "net.ipv4.conf.default.secure_redirects" = 1;
      # Protect against tcp time-wait assassination hazards
      "net.ipv4.tcp_rfc1337" = 1;
      # TCP Fast Open (TFO)
      "net.ipv4.tcp_fastopen" = 0;
      # Bufferbloat mitigations
      # Requires >= 4.9 & kernel module
      "net.ipv4.tcp_congestion_control" = "bbr";
      # Requires >= 4.19
      "net.core.default_qdisc" = "cake";

      "net.ipv4.tcp_rmem" = "4096 87380 2500000";
      "net.ipv4.tcp_wmem" = "4096 65536 2500000";
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.core.somaxconn" = 4096;
      "net.ipv4.conf.all.send_redirects" = 0;

      "net.ipv4.tcp_tw_recycle" = 0;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_no_metrics_save" = 1;

      # hardend
      "net.ipv4.tcp_sack" = 1;
      "net.ipv4.tcp_dsack" = 0;
      "net.ipv4.tcp_fack" = 0;

      "kernel.yama.ptrace_scope" = 2;
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;

      "fs.protected_symlinks" = 1;
      "fs.protected_hardlinks" = 1;

      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;

      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "vm.swappiness" = 150;
      "vm.max_map_count" = 2147483642;
      "net.ipv4.tcp_ecn" = 1;
    };
  };
}

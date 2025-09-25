# WARNING: this will cause virtualization guest fail to boot
_: {
  boot = {
    kernel.sysctl = {
      "kernel.panic" = 10;
      "kernel.sysrq" = 1;
      # max read buffer
      # max write buffer
      "fs.file-max" = 6553560;

      # Ignore ICMP broadcasts to avoid participating in Smurf attacks
      "net.ipv4.icmp_echo_ignore_broadcasts" = 0;
      "net.core.netdev_budget" = 600;

      "net.core.netdev_tstamp_prequeue" = 0;
      "net.core.dev_weight" = 256;

      # Ignore bad ICMP errors
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse-path filter for spoof protection
      "net.ipv4.conf.default.rp_filter" = 0;
      # SYN flood protection
      "net.ipv4.tcp_syncookies" = 0;
      "net.ipv4.tcp_syn_retries" = 2;
      # Do not accept ICMP redirects (prevent MITM attacks)
      "net.ipv4.conf.default.accept_redirects" = 1;
      "net.ipv4.conf.all.secure_redirects" = 1;
      "net.ipv4.conf.default.secure_redirects" = 1;

      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.rp_filter" = 0;

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
      "vm.max_map_count" = 2147483642;
      "net.ipv4.tcp_ecn" = 1;

      # use as little swap space as possible
      "vm.swappiness" = 1;

      # prioritize application RAM against disk/swap cache
      "vm.vfs_cache_pressure" = 50;

      # minimum free memory
      "vm.min_free_kbytes" = 1000000;

      # follow mellanox best practices https://community.mellanox.com/s/article/linux-sysctl-tuning
      # the following changes are recommended for improving IPv4 traffic performance by Mellanox

      # disable the TCP timestamps option for better CPU utilization
      "net.ipv4.tcp_timestamps" = 0;

      # increase the maximum length of processor input queues
      "net.core.netdev_max_backlog" = 250000;

      "net.core.rmem_default" = 4194304;
      "net.core.wmem_default" = 4194304;
      "net.core.optmem_max" = 4194304;

      # enable low latency mode for TCP:
      "net.ipv4.tcp_low_latency" = 1;

      # the following variable is used to tell the kernel how much of the socket buffer
      # space should be used for TCP window size, and how much to save for an application
      # buffer. A value of 1 means the socket buffer will be divided evenly between.
      # TCP windows size and application.
      "net.ipv4.tcp_adv_win_scale" = 1;

      # maximum number of incoming connections
      "net.core.somaxconn" = 65535;

      # queue length of completely established sockets waiting for accept
      "net.ipv4.tcp_max_syn_backlog" = 4096;

      # time to wait (seconds) for FIN packet
      "net.ipv4.tcp_fin_timeout" = 15;

      # disable icmp accept redirect
      "net.ipv4.conf.all.accept_redirects" = 0;

      # drop packets with LSR or SSR
      "net.ipv4.conf.all.accept_source_route" = 0;

      # MTU discovery, only enable when ICMP blackhole detected
      "net.ipv4.tcp_mtu_probing" = 1;
    };
  };
}

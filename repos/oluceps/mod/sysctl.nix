{
  flake.modules.nixos.sysctl = _: {
    boot.kernel.sysctl = {
      "kernel.panic" = 10;
      "kernel.sysrq" = 183;

      # max open files (kept generous)
      "fs.file-max" = 6553560;

      # decrease cache pressure to keep inodes and dentries in memory (was 200)
      "vm.vfs_cache_pressure" = 50;

      # default read buffer: expanded to 1mb for abundant memory
      "net.core.rmem_default" = 1048576;
      # default write buffer: expanded to 1mb
      "net.core.wmem_default" = 1048576;

      # max read buffer: expanded to 32mb
      "net.core.rmem_max" = 33554432;
      # max write buffer: expanded to 32mb
      "net.core.wmem_max" = 33554432;

      # scale tcp buffers (min, default, max) to match max buffers
      "net.ipv4.tcp_rmem" = "4096 1048576 33554432";
      "net.ipv4.tcp_wmem" = "4096 1048576 33554432";

      # allow more packets to be processed in one softirq
      "net.core.netdev_budget" = 1000;

      # max processor input queue (uncommented and increased for heavy traffic)
      "net.core.netdev_max_backlog" = 16384;

      # max listen backlog
      "net.core.somaxconn" = 16384;

      "net.ipv4.conf.all.arp_accept" = 1;

      "net.ipv6.conf.all.accept_ra" = 2;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.rp_filter" = 0;
      "net.ipv6.conf.all.rp_filter" = 0;
      "net.ipv4.conf.lo.rp_filter" = 0;
      "net.ipv6.conf.lo.rp_filter" = 0;
      "net.ipv4.ip_nonlocal_bind" = 1;

      # ignore icmp broadcasts to avoid participating in smurf attacks
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      # ignore bad icmp errors
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

      # syn flood protection
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_syn_retries" = 2;

      # do not accept icmp redirects (prevent mitm attacks)
      "net.ipv4.conf.all.secure_redirects" = 1;
      "net.ipv4.conf.default.secure_redirects" = 1;
      "net.ipv4.conf.all.send_redirects" = 0;

      # protect against tcp time-wait assassination hazards
      "net.ipv4.tcp_rfc1337" = 1;

      # enable tcp fast open for both incoming and outgoing connections (was 0)
      "net.ipv4.tcp_fastopen" = 3;

      # bufferbloat mitigations
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_mtu_probing" = 1;

      # note: tcp_tw_recycle was removed in linux 4.12, safe to remove entirely
      # "net.ipv4.tcp_tw_recycle" = 0;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_no_metrics_save" = 1;

      # hardened
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

      # reduce swappiness further since ram is abundant
      "vm.swappiness" = 20;
      "kernel.task_delayacct" = 1;

      # prevent kswapd0 cpu spikes by disabling aggressive watermark boosting
      "vm.watermark_boost_factor" = 0;

      # optimize zswap single-page access by disabling swap read-ahead
      "vm.page-cluster" = 0;

      # trigger background disk writeback by absolute bytes (e.g., 128mb / 512mb) instead of ratio
      # this effectively prevents i/o stalls on large memory systems with btrfs
      "vm.dirty_background_bytes" = 134217728;
      "vm.dirty_bytes" = 536870912;
      # setting explicit bytes overrides ratio values, so ratio should be set to 0
      "vm.dirty_background_ratio" = 0;
      "vm.dirty_ratio" = 0;

      "vm.max_map_count" = 2147483642;
      "net.ipv4.tcp_ecn" = 1;
      "net.ipv6.tcp_ecn" = 1;
    };

  };
}

{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot.kernelModules = [
    "tcp_bbr"
    # preload to make sysctl options avaliable
    "nf_conntrack"
  ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "cake";
    "net.core.somaxconn" = 65536;
    "net.core.netdev_max_backlog" = 10000;
    "net.core.netdev_budget" = 600;
    "net.core.rps_sock_flow_entries" = 32768;
    "net.core.dev_weight" = 600;

    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    "net.ipv4.tcp_keepalive_probes" = 6;
    "net.ipv4.tcp_mtu_probing" = true;

    # tcp pending
    "net.ipv4.tcp_max_syn_backlog" = 65536;
    "net.ipv4.tcp_max_tw_buckets" = 2000000;
    "net.ipv4.tcp_tw_reuse" = true;
    "net.ipv4.tcp_fin_timeout" = 10;
    "net.ipv4.tcp_slow_start_after_idle" = false;

    # net mem
    "net.core.rmem_default" = 1048576;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_default" = 1048576;
    "net.core.wmem_max" = 16777216;
    "net.core.optmem_max" = 65536;
    "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.udp_rmem_min" = 8192;
    "net.ipv4.udp_wmem_min" = 8192;

    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.default.forwarding" = true;
    "net.ipv4.conf.all.rp_filter" = true;
    "net.ipv4.conf.default.rp_filter" = true;

    "net.netfilter.nf_conntrack_buckets" = 393216;
    "net.netfilter.nf_conntrack_max" = 393216;
    "net.netfilter.nf_conntrack_generic_timeout" = 60;
    "net.netfilter.nf_conntrack_tcp_timeout_fin_wait" = 10;
    "net.netfilter.nf_conntrack_tcp_timeout_established" = 600;
    "net.netfilter.nf_conntrack_tcp_timeout_time_wait" = 5;
  };

  services.timesyncd.extraConfig = ''
    PollIntervalMinSec=16
    PollIntervalMaxSec=180
    ConnectionRetrySec=3
  '';
  systemd.additionalUpstreamSystemUnits = [
    "systemd-time-wait-sync.service"
  ];
  services.fake-hwclock.enable = true;
  networking.timeServers = [
    "ntp.aliyun.com"
    "ntp1.aliyun.com"
    "ntp2.aliyun.com"
    "ntp3.aliyun.com"
    "ntp4.aliyun.com"
    "ntp5.aliyun.com"
    "ntp6.aliyun.com"
    "ntp7.aliyun.com"
  ];

  # required to set hostname, see <https://github.com/systemd/systemd/issues/16656>
  security.polkit.enable = true;

  networking.useNetworkd = false;
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;
  networking.firewall.enable = false;

  systemd.network.enable = true;
  systemd.network.config = {
    networkConfig = {
      ManageForeignRoutingPolicyRules = false;
      SpeedMeter = true;
    };
  };

  systemd.services."systemd-networkd" = {
    serviceConfig = {
      # avoid infinity restarting,
      # we want to tty into the system as network is not functional
      Restart = "no";
    };
  };
  systemd.network.wait-online = {
    ignoredInterfaces = [ "tun0" ];
    timeout = 20;
  };

  systemd.network.links."10-intern0" = {
    matchConfig.Path = "platform-ff540000.ethernet";
    linkConfig = {
      Name = "intern0";
      MACAddress = "fe:1b:f3:16:82:a6";
      RxBufferSize = 1024;
      TxBufferSize = 1024;
      TransmitQueueLength = 2000;
      TCPSegmentationOffload = false;
      TCP6SegmentationOffload = false;
    };
  };

  systemd.network.links."10-extern0" = {
    matchConfig.Path = "platform-xhci-hcd.0.auto-usb-0:1:1.0";
    linkConfig = {
      Name = "extern0";
      MACAddress = "ea:ce:b4:a1:ce:94";
      RxBufferSize = 4096;
      TransmitQueueLength = 2000;
      TCPSegmentationOffload = false;
      TCP6SegmentationOffload = false;
    };
  };

  systemd.network.networks."11-intern0" = {
    name = "intern0";
    networkConfig = {
      Address = "192.168.1.1/24";
      ConfigureWithoutCarrier = true;
      # DHCPServer = true;
      IPv6SendRA = true;
      DHCPPrefixDelegation = true;
    };
    # dhcpServerConfig = {
    #   PoolOffset = 2;
    #   DefaultLeaseTimeSec = "12h";
    #   MaxLeaseTimeSec = "24h";
    #   UplinkInterface = "extern0";
    #   DNS = [ "_server_address" ];
    # };
    dhcpPrefixDelegationConfig = {
      UplinkInterface = "extern0";
      Token = "static:::1";
    };
    ipv6SendRAConfig = {
      EmitDNS = true;
      DNS = [ "_link_local" ];
    };
    linkConfig.ActivationPolicy = "always-up";
  };

  systemd.network.networks."11-extern0" = {
    name = "extern0";
    networkConfig = {
      Address = "192.168.4.16/24";
      ConfigureWithoutCarrier = true;
      DHCP = "yes";
    };
    dhcpV4Config = {
      SendHostname = true;
      # UseRoutes = false;
    };
    dhcpV6Config = {
      WithoutRA = "solicit";
      PrefixDelegationHint = "::/64";
      # use SLAAC addresses only
      UseAddress = false;
    };
    linkConfig.ActivationPolicy = "always-up";
    # routes = [{
    #   routeConfig = {
    #     Gateway = "_dhcp4";
    #     PreferredSource = "192.168.1.1";
    #   };
    # }];
  };

  ## Uncoment after https://github.com/SagerNet/sing-tun/pull/16 being merged
  #
  # systemd.network.netdevs."tun0" = {
  #   netdevConfig = {
  #     Name = "tun0";
  #     Kind = "tun";
  #   };
  # };
  systemd.network.networks."tun0" = {
    matchConfig.Name = "tun0";
    networkConfig = {
      Address = "198.18.0.1/15";
      ConfigureWithoutCarrier = true;
    };
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = "198.18.0.2";
        Metric = 1;
        Table = 200;
      }
    ];
    routingPolicyRules = [
      {
        FirewallMark = 10;
        Table = 200;
      }
    ];
  };

  systemd.services."tweak-network-settings" = {
    description = "Tweak network settings";
    serviceConfig = {
      Type = "simple";
    };
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    script = ''
      # The {Rx,Tx}BufferSize systemd.link options for intern0 is not working, set manually
      ${pkgs.ethtool}/bin/ethtool -G intern0 rx 1024
      ${pkgs.ethtool}/bin/ethtool -G intern0 tx 1024

      ## Figure out why use these CPU mask combination?

      # 8(0b1000, CPU3) for 24(xhci-hcd:usb4, extern0)
      echo 8 > /proc/irq/24/smp_affinity
      # 2(0b0010, CPU1) for 47(intern0)
      echo 2 > /proc/irq/47/smp_affinity

      # 7(0b0111, CPU0-2)
      echo 7 > /sys/class/net/extern0/queues/rx-0/rps_cpus
      # d(0b1101, CPU0,CPU2-3)
      echo d > /sys/class/net/intern0/queues/rx-0/rps_cpus

      echo 2048 > /sys/class/net/extern0/queues/rx-0/rps_flow_cnt
      echo 2048 > /sys/class/net/intern0/queues/rx-0/rps_flow_cnt
    '';
  };
}

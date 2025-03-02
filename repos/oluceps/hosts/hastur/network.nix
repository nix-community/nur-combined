{ lib, config, ... }:
{
  imports = [ ./bird.nix ];
  services.resolved = {
    enable = lib.mkForce false;
    llmnr = "false";
    dnssec = "false";
    extraConfig = ''
      MulticastDNS=off
    '';
    fallbackDns = [ "8.8.8.8#dns.google" ];
    # dnsovertls = "true";
  };
  networking = {
    timeServers = [
      "ntp.sjtu.edu.cn"
      "ntp1.aliyun.com"
      "ntp.ntsc.ac.cn"
      "cn.ntp.org.cn"
    ];
    usePredictableInterfaceNames = false;
    resolvconf.useLocalResolver = true;
    nameservers = [
      "223.5.5.5#dns.alidns.com"
      "120.53.53.53#dot.pub"
    ];
    # useHostResolvConf = true;
    hosts = lib.data.hosts.${config.networking.hostName};

    hostName = "hastur"; # Define your hostname.
    domain = "nyaw.xyz";
    # replicates the default behaviour.
    enableIPv6 = true;
    # WARNING: THIS FAILED MY DHCP
    # interfaces.eth0.wakeOnLan.enable = true;
    wireless.iwd.enable = true;
    useNetworkd = true;
    useDHCP = false;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [
        "virbr0"
        "podman*"
        "dae0"
      ];
      allowedUDPPorts = [
        8080
      ];
      allowedTCPPorts = [
        8080
      ];
    };
    nftables = {
      enable = true;
    };
    networkmanager.enable = lib.mkForce false;
    networkmanager.dns = "none";
  };
  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      anyInterface = true;
      ignoredInterfaces = [
        "wlan0"
        "wg0"
      ];
    };

    links."10-eth0" = {
      matchConfig.MACAddress = "3c:7c:3f:22:49:80";
      linkConfig.Name = "eth0";
    };

    links."30-rndis" = {
      matchConfig.Driver = "rndis_host";
      linkConfig = {
        NamePolicy = "keep";
        Name = "rndis";
        MACAddressPolicy = "persistent";
      };
    };
    links."20-ncm" = {
      matchConfig.Driver = "cdc_ncm";
      linkConfig = {
        NamePolicy = "keep";
        Name = "ncm";
        MACAddressPolicy = "persistent";
      };
    };
    networks."8-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "no";
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        IPv6AcceptRA = "yes";
      };
      ipv6AcceptRAConfig = {
        UseDNS = false;
      };

      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;

      linkConfig.RequiredForOnline = "routable";
      address = [ "192.168.1.2/24" ];
      routes = [
        { Gateway = "192.168.1.1"; }
      ];
    };

    networks."25-ncm" = {
      matchConfig.Name = "ncm";
      DHCP = "yes";
      dhcpV4Config.RouteMetric = 2044;
      dhcpV6Config.RouteMetric = 2044;
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
      networkConfig = {
        DNSSEC = true;
      };
    };

    networks."30-rndis" = {
      matchConfig.Name = "rndis";
      DHCP = "yes";
      dhcpV4Config.RouteMetric = 2044;
      dhcpV6Config.RouteMetric = 2044;
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
      networkConfig = {
        DNSSEC = false;
      };
    };

  };
}

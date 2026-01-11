{
  config,
  pkgs,
  lib,
  ...
}:
{
  networking.nftables = {
    enable = true;
    checkRuleset = false;
    rulesetFile = ./files/nftables.nft;
  };
  systemd.services.nftables = {
    wants = lib.mkForce [ "network-online.target" ];
    before = lib.mkForce [ ];
    after = [ "network-online.target" ];
  };

  services.einat = {
    enable = true;
    config.defaults = rec {
      tcp_ranges = [
        "10000-32767"
        "61000-65535"
      ];
      udp_ranges = tcp_ranges;
    };
    config.interfaces = [
      {
        if_name = "extern0";
        nat44 = true;
        snat_internals = [
          "192.168.1.0/24"
        ];
        ipv4_hairpin_route.internal_if_names = [
          "lo"
          "intern0"
        ];
      }
    ];
  };

  networking.resolvconf.useLocalResolver = true;
  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      no-resolv = true;
      strict-order = true;
      server = [ "127.0.0.1#5353" "223.5.5.5#53" ];
      local = "/lan/";
      interface = "intern0";
      bind-interfaces = true;
      address = "/nixos-r2s.lan/192.168.1.1";
      # TODO: build additional hosts from DHCPv6 leases and LAN interface addresses
      #addn-hosts=hosts_from_dhcpv6_leases
      domain = "lan";
      dhcp-range = "192.168.1.3,192.168.1.255,255.255.255.0,24h";
      cache-size = 0;
      no-negcache = true;
    };
  };
  systemd.services.dnsmasq = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  services.v2ray-rules-dat = {
    enable = true;
    dates = "6:30";
    randomizedDelaySec = "30min";
  };

  services.mosdns = {
    enable = false;
    configFile = config.sops.secrets."mosdns.yaml".path;
  };
  systemd.services.mosdns = {
    preStart = ''
      mkdir -p /var/lib/mosdns
    '';
  };

  sops.secrets."mosdns.yaml".restartUnits = [ "mosdns.service" ];
  services.v2ray-rules-dat.reloadServices = [ "mosdns.service" ];
}

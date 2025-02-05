{ lib, config, ... }:
{
  services.babeld = {
    enable = true;
    config = ''
      skip-kernel-setup true
      local-path /var/run/babeld/ro.sock
      router-id ac:1f:6b:e5:fe:3a

      interface wg-yidhra type tunnel rtt-min 50 rtt-max 256
      interface wg-abhoth type tunnel rtt-min 160 rtt-max 256
      interface wg-azasos type tunnel rtt-min 40 rtt-max 256
      interface wg-kaambl type tunnel rtt-min 20 rtt-max 256 rtt-decay 32
      interface wg-hastur type tunnel rtt-min 0.5 rtt-max 256 rtt-decay 32

      redistribute ip fdcc::/64 ge 64 le 128 local allow
      redistribute proto 42
      redistribute local deny
    '';
  };
  networking = {
    resolvconf.useLocalResolver = true;
    hosts = lib.data.hosts.${config.networking.hostName};
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
      ] ++ map (n: "wg-${n}") (builtins.attrNames (lib.conn { }));
      allowedUDPPorts = [
        80
        443
        8080
        5173
        23180
        4444
        51820
        1935
        1985
        10080
        8000
      ];
      allowedTCPPorts = [
        80
        443
        8080
        9900
        2222
        5173
        8448
        1935
        1985
        10080
        8000
        9000
        9001

        6800
      ];

      allowedTCPPortRanges = [
        {
          from = 10000;
          to = 10010;
        }
        {
          from = 6881;
          to = 6999;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 6881;
          to = 6999;
        }
      ];
    };
    hostId = "0bc55a2e";
    useNetworkd = true;
    useDHCP = false;

    hostName = "eihort";
    domain = "nyaw.xyz";
    enableIPv6 = true;
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
        "wg*"
      ];
    };

    links."eth0" = {
      matchConfig.MACAddress = "ac:1f:6b:e5:fe:3a";
      linkConfig = {
        Name = "eth0";
        WakeOnLan = "magic";
      };
    };

    links."eth1" = {
      matchConfig.MACAddress = "ac:1f:6b:e5:fe:3b";
      linkConfig = {
        Name = "eth1";
        WakeOnLan = "magic";
      };
    };

    networks = {
      "5-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = "no";
          IPv4Forwarding = true;
          IPv6Forwarding = true;
          IPv6AcceptRA = "yes";
        };
        linkConfig.RequiredForOnline = "routable";
        address = [ "192.168.1.16/24" ];
        routes = [
          { Gateway = "192.168.1.1"; }
        ];
      };
    };
  };
}

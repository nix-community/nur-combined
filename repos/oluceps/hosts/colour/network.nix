{ lib, config, ... }:
{
  networking = {
    domain = "nyaw.xyz";
    resolvconf.useLocalResolver = true;
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "wg0"
        "wg1"
      ];
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
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "colour";
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
        "wg0"
        "wg1"
      ];
    };

    links."eth0" = {
      matchConfig.MACAddress = "00:22:48:67:8d:4a";
      linkConfig.Name = "eth0";
    };

    netdevs = {
    };

    networks = {
      "15-wg2" = {

        matchConfig.Name = "wg2";
        address = [
          # "172.16.0.2/32"
          "2606:4700:110:82bf:db9a:4a73:b4e3:5b57/128"
        ];
        networkConfig = {
          IPMasquerade = "ipv6";
          IPv4Forwarding = true;
        };

        routes = [
          {
            Destination = "::/0";
            Gateway = "fe80::1";
            Scope = "link";
          }
        ];
      };

      "20-wired" = {
        matchConfig.Name = "eth0";
        DHCP = "yes";
        # address = [
        #   "10.0.0.10"
        # ];

        # routes = [
        #   { routeConfig.Gateway = "10.0.0.1"; }
        # ];
      };
    };
  };
}

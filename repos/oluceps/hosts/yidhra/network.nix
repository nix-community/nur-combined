{ lib, ... }:
{
  systemd.services.systemd-networkd.serviceConfig.Environment = [ "SYSTEMD_LOG_LEVEL=debug" ];
  imports = [ ./bird.nix ];
  networking = {
    domain = "nyaw.xyz";
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
      ];
      allowedUDPPorts = [
        80
        443
      ];
      allowedTCPPorts = [
        80
        443
        40119 # stls
        8776 # forward radicle
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "yidhra";
    enableIPv6 = true;

    nftables = {
      enable = true;
      # for hysteria port hopping
      ruleset = ''
        define INGRESS_INTERFACE="eth0"
        define PORT_RANGE=20000-50000
        define HYSTERIA_SERVER_PORT=4432

        table inet hysteria_porthopping {
          chain prerouting {
            type nat hook prerouting priority dstnat; policy accept;
            iifname $INGRESS_INTERFACE udp dport $PORT_RANGE counter redirect to :$HYSTERIA_SERVER_PORT
          }
        }
      '';
    };
    networkmanager.enable = lib.mkForce false;
    networkmanager.dns = "none";

  };

  services = {
    resolved = {
      dnssec = "false";
      llmnr = "false";
      extraConfig = ''
        MulticastDNS=off
      '';
    };
  };

  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      anyInterface = true;
      ignoredInterfaces = [
      ];
    };

    links."10-eth0" = {
      matchConfig.MACAddress = "fa:51:33:18:0a:00";
      linkConfig.Name = "eth0";
    };

    networks."8-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "no";
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        IPv6AcceptRA = true;
        MulticastDNS = true;
      };
      ipv6AcceptRAConfig = {
        DHCPv6Client = false;
        # UseDNS = false;
      };

      address = [
        "205.198.76.6/24"
        "2404:c140:2000:2::32:1d9f/64"
      ];
      linkConfig.RequiredForOnline = "routable";
      routes = [
        { Gateway = "205.198.76.1"; }
        {
          Gateway = "2404:c140:2000:2::1";
          GatewayOnLink = true;
        }
      ];
    };
  };
}

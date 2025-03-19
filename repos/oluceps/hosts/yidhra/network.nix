{ config, lib, ... }:
{
  imports = [ ./bird.nix ];
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';
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

  services.resolved = {
    enable = lib.mkForce false;
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
      matchConfig.MACAddress = "00:16:3e:0c:cd:5d";
      linkConfig.Name = "eth0";
    };

    # netdevs."20-warp" = {
    #   netdevConfig = {
    #     Kind = "wireguard";
    #     Name = "warp";
    #     MTUBytes = "1280";
    #   };
    #   wireguardConfig = {
    #     PrivateKeyFile = config.vaultix.secrets.wgy-warp.path;
    #   };
    #   wireguardPeers = [
    #     {
    #       PublicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
    #       Endpoint = "162.159.192.1:2408";
    #       AllowedIPs = [ "::/0" ];
    #     }
    #   ];
    # };
    networks = {

      "20-eth0" = {
        matchConfig.Name = "eth0";
        DHCP = "yes";
      };
      # "15-wireguard-warp" = {
      #   matchConfig.Name = "warp";
      #   address = [
      #     # "2606:4700:110:80ef:47c4:b370:7dbd:2a72/128"
      #     "2606:4700:110:88f7:7b28:e45:e5d1:9f7b/128"
      #   ];
      #   networkConfig = {
      #     IPMasquerade = "ipv6";
      #     IPv4Forwarding = true;
      #   };

      #   routes = [
      #     {
      #       Destination = "::/0";
      #       Gateway = "fe80::1";
      #     }
      #   ];
      # };
    };
  };
}

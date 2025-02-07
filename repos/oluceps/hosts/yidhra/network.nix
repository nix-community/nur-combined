{ config, lib, ... }:
{
  services.babeld = {
    enable = true;
    config = ''
      skip-kernel-setup true
      local-path /var/run/babeld/ro.sock
      router-id 00:16:3e:0c:cd:5d

      interface wg-abhoth type tunnel rtt-min 64 rtt-max 256
      interface wg-hastur type tunnel rtt-min 55 rtt-max 256
      interface wg-azasos type tunnel rtt-min 42 rtt-max 256
      interface wg-kaambl type tunnel rtt-min 70 rtt-max 256 rtt-decay 120
      interface wg-eihort type tunnel rtt-min 48 rtt-max 256 rtt-decay 60

      redistribute ip fdcc::/64 ge 64 le 128 local allow
      redistribute proto 42
      redistribute local deny
    '';
  };

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
        table ip nat {
        	chain prerouting {
        		type nat hook prerouting priority filter; policy accept;
        		iifname "eth0" udp dport 40000-50000 counter packets 0 bytes 0 dnat to :4432
        	}
        }
        table ip6 nat {
        	chain prerouting {
        		type nat hook prerouting priority filter; policy accept;
        		iifname "eth0" udp dport 40000-50000 counter packets 0 bytes 0 dnat to :4432
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

    netdevs.wg-warp = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg-warp";
        MTUBytes = "1300";
      };
      wireguardConfig = {
        PrivateKeyFile = config.vaultix.secrets.wgy-warp.path;
      };
      wireguardPeers = [
        {
          PublicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
          Endpoint = "162.159.192.1:2408";
          AllowedIPs = [ "::/0" ];
          PersistentKeepalive = 15;
        }
      ];
    };
    networks = {

      "20-eth0" = {
        matchConfig.Name = "eth0";
        DHCP = "yes";
      };
      "15-wg-warp" = {
        matchConfig.Name = "wg-warp";
        address = [
          "2606:4700:110:80ef:47c4:b370:7dbd:2a72/128"
        ];
        networkConfig = {
          IPMasquerade = "ipv6";
          IPv4Forwarding = true;
        };

        routes = [
          {
            Destination = "::/0";
            Gateway = "fe80::1";
          }
        ];
      };
    };
  };
}

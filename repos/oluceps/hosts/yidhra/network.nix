{ config, lib, ... }:
{
  services.babeld = {
    enable = true;
    config = ''
      skip-kernel-setup true
      local-path /var/run/babeld/ro.sock
      router-id 00:16:3e:0c:cd:5d
      ${lib.concatStringsSep "\n" (
        map (n: "interface wg-${n} type tunnel rtt-max 512") builtins.attrNames
          (lib.conn { }).${config.networking.hostName}
      )}
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
      extraForwardRules = "iifname wg0 accept";
      trustedInterfaces = [
        "virbr0"
      ];
      allowedUDPPorts = [
        80
        443
        8080
        5173
        23180
        4444
        51820
      ];
      allowedTCPPorts = [
        80
        443
        8080
        9900
        2222
        40119 # stls
        5173
        8448
        8776
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

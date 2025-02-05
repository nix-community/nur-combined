{ config, lib, ... }:
{
  services.babeld = {
    enable = true;
    config = ''
      skip-kernel-setup true
      local-path /var/run/babeld/ro.sock
      router-id f2:3c:95:50:a1:73
      ${lib.concatStringsSep "\n" (
        map (n: "interface wg-${n} type tunnel rtt-max 512") (builtins.attrNames (lib.conn { }))
      )}
      redistribute ip fdcc::/64 ge 64 le 128 local allow
      redistribute proto 42
      redistribute local deny
    '';
  };
  services = {
    resolved.enable = lib.mkForce false;
  };
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';
  networking = {
    domain = "nyaw.xyz";
    # resolvconf.useLocalResolver = true;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [
        "virbr0"
        "wg*"
      ];
      allowedUDPPortRanges = [
        {
          from = 51820;
          to = 51830;
        }
      ];
      allowedUDPPorts = [
        80
        443
        8080
        5173
        23180
        4444
        3330
        8880
        34197 # factorio realm
      ];
      allowedTCPPorts = [
        80
        443
        8080
        9900
        2222
        5173
        8448
        3330
        8880
        40119 # stls
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "abhoth";
    enableIPv6 = false;

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
  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      anyInterface = true;
      ignoredInterfaces = [
        "wg0"
      ];
    };

    links."10-eth0" = {
      matchConfig.MACAddress = "f2:3c:95:50:77:31";
      linkConfig.Name = "eth0";
    };

    networks."20-eth0" = {
      matchConfig.Name = "eth0";
      DHCP = "yes";
    };

  };
}

{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.network;
  doof_if = "wg-doof";
  tunnelName = "doofTun";
in
{
  options.vacu.network.doofPubKey = mkOption { type = types.str; };
  config = {
    vacu.network.ips = {
      doofStatic4 = "205.201.63.13";
      doofStatic6 = "2602:fce8:106:10::1";
    };
    vacu.network.doofPubKey = "nuESyYEJ3YU0hTZZgAd7iHBz1ytWBVM5PjEL1VEoTkU=";
    vacu.packages = [ "wireguard-tools" ];
    sops.secrets.wireguardKey = {
      owner = config.users.users.systemd-network.name;
    };
    systemd.network.config.routeTables.${tunnelName} = 422;
    systemd.network.config.addRouteTablesToIPRoute2 = true;
    systemd.network.netdevs.${doof_if} = {
      netdevConfig = {
        Kind = "wireguard";
        Name = doof_if;
        MTUBytes = 1300;
      };
      wireguardConfig = {
        # FirewallMark = "0xd00f";
        PrivateKeyFile = config.sops.secrets.wireguardKey.path;
      };
      wireguardPeers = lib.singleton {
        PublicKey = cfg.doofPubKey;
        Endpoint = "tun-sea.doof.net:53263";
        AllowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        PersistentKeepalive = 5;
      };
    };
    systemd.network.networks."15-doof" = {
      matchConfig.Name = doof_if;
      DHCP = "no";
      networkConfig.IPv6AcceptRA = false;
      routes = [
        {
          Gateway = "205.201.63.44"; # tun-sea.doof.net
          GatewayOnLink = true;
          Source = "${cfg.ips.doofStatic4}/32";
          Destination = "0.0.0.0/0";
          Table = tunnelName;
        }
      ];
      routingPolicyRules = [
        {
          From = "${cfg.ips.doofStatic4}/32";
          To = cfg.ips.t2dSubnets;
          Table = "main";
        }
        {
          From = "${cfg.ips.doofStatic4}/32";
          Table = tunnelName;
        }
      ];
    };
    systemd.network.networks.${cfg.lan_bridge_network} = {
      address = lib.mkAfter [ "${cfg.ips.doofStatic4}/32" ];
    };
  };
}

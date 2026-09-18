{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.network;
  doof_if = "wg-doof";
  tunnelName = "doofTun";
  vmPolicyRules = lib.concatMap (vmName: [
    {
      Family = "both";
      IncomingInterface = "v-${vmName}";
      Table = "main";
      SuppressPrefixLength = 0;
      Priority = 125;
    }
    {
      Family = "both";
      IncomingInterface = "v-${vmName}";
      Table = tunnelName;
      Priority = 150;
    }
  ]) (lib.attrNames config.vacu.qemuVMs);
in
{
  options.vacu.network.doofPubKey = mkOption { type = types.str; };
  config = {
    vacu.network.ips = {
      doofStatic4 = "205.201.63.13";
      doofStatic6 = "2602:fce8:106:10::1";
      doofStaticRange6 = "2602:fce8:106:10::/64";
    };
    vacu.network.doofPubKey = "nuESyYEJ3YU0hTZZgAd7iHBz1ytWBVM5PjEL1VEoTkU=";
    vacu.packages = [ "wireguard-tools" ];
    sops.secrets.wireguardKey = {
      owner = config.users.users.systemd-network.name;
    };
    services.radvd = {
      enable = true;
      config = ''
        interface br-main {
          AdvSendAdvert on;
          AdvDefaultLifetime 0;
          route ${cfg.ips.doofStaticRange6} { };
        };
      '';
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
        {
          Gateway = "2602:fce8:1::ab";
          GatewayOnLink = true;
          Source = cfg.ips.doofStaticRange6;
          Destination = "::/0";
          Table = tunnelName;
        }
      ];
      # Prefer specific routes in the main table, but suppress its default
      # routes so all other traffic sourced from the Doof addresses falls
      # through to the tunnel table.
      routingPolicyRules = [
        {
          Family = "ipv4";
          From = "${cfg.ips.doofStatic4}/32";
          Table = "main";
          SuppressPrefixLength = 0;
          Priority = 100;
        }
        {
          Family = "ipv6";
          From = cfg.ips.doofStaticRange6;
          Table = "main";
          SuppressPrefixLength = 0;
          Priority = 100;
        }
        {
          Family = "ipv4";
          From = "${cfg.ips.doofStatic4}/32";
          Table = tunnelName;
          Priority = 200;
        }
        {
          Family = "ipv6";
          From = cfg.ips.doofStaticRange6;
          Table = tunnelName;
          Priority = 200;
        }
      ]
      ++ vmPolicyRules;
    };
    systemd.network.networks.${cfg.lan_bridge_network} = {
      address = lib.mkAfter [
        "${cfg.ips.doofStatic4}/32"
        "${cfg.ips.doofStatic6}/128"
      ];
    };

    # IPv4 guests use private addresses, so pin their translated source to the
    # public Doof address. IPv6 guests hold routed /128s and need no NAT.
    networking.firewall.extraCommands = ''
      iptables -t nat -N vacuvm-doof 2>/dev/null || true
      iptables -t nat -F vacuvm-doof
      iptables -t nat -A vacuvm-doof -s ${config.vacu.vmNet.v4Prefix}.0/24 -o ${doof_if} -j SNAT --to-source ${cfg.ips.doofStatic4}
      # iptables -t nat -A vacuvm-doof -s ${config.vacu.vmNet.v4Prefix}.0/24 -o ${doof_if} -j MASQUERADE
      iptables -t nat -C POSTROUTING -j vacuvm-doof 2>/dev/null \
        || iptables -t nat -A POSTROUTING -j vacuvm-doof

      iptables -N vacuvm-doof-forward 2>/dev/null | true
      iptables -F vacuvm-doof-forward
      iptables -A vacuvm-doof-forward -i 'v-*' -o ${doof_if} -j ACCEPT
      iptables -C FORWARD -j vacuvm-doof-forward 2>/dev/null \
        || iptables -A FORWARD -j vacuvm-doof-forward
    '';
    networking.firewall.extraStopCommands = ''
      iptables -t nat -D POSTROUTING -j vacuvm-doof 2>/dev/null || true
      iptables -t nat -F vacuvm-doof 2>/dev/null || true
      iptables -t nat -X vacuvm-doof 2>/dev/null || true

      iptables -D FORWARD -j vacuvm-doof-forward 2>/dev/null || true
      iptables -F vacuvm-doof-forward 2>/dev/null || true
      iptables -X vacuvm-doof-forward 2>/dev/null || true
    '';
  };
}

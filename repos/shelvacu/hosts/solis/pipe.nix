{ lib, config, ... }:
let
  ifName = "solop";
in
{
  systemd.network.netdevs.${ifName} = {
    netdevConfig = {
      Kind = "wireguard";
      Name = ifName;
      MTUBytes = 1300;
    };
    wireguardConfig = {
      # FirewallMark = "0xd00f";
      PrivateKeyFile = "/root/wg.key";
    };
    wireguardPeers = lib.singleton {
      PublicKey = config.vacu.hosts.prophecy.wireguardKey;
      Endpoint = config.vacu.hosts.prophecy.primaryIp;
      AllowedIPs = [ "140.233.190.10/32" ];
      PersistentKeepalive = 5;
    };
  };
  # systemd.network.networks."15-doof" = {
  #   matchConfig.Name = ifName;
  #   DHCP = "no";
  #   networkConfig.IPv6AcceptRA = false;
  #   routes = [
  #     {
  #       Gateway = "205.201.63.44"; # tun-sea.doof.net
  #       GatewayOnLink = true;
  #       Source = "${cfg.ips.doofStatic4}/32";
  #       Destination = "0.0.0.0/0";
  #       Table = tunnelName;
  #     }
  #   ];
  #   routingPolicyRules = [
  #     {
  #       From = "${cfg.ips.doofStatic4}/32";
  #       To = cfg.ips.t2dSubnets;
  #       Table = "main";
  #     }
  #     {
  #       From = "${cfg.ips.doofStatic4}/32";
  #       Table = tunnelName;
  #     }
  #   ];
  # };
}

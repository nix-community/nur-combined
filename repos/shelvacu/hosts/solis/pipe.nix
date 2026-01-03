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
}

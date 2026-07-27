{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.services.wireguard.server;

  secretPath = ../../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);
  allowedIPs = lists.optionals secretCondition (import secretPath).wireguard.kerkouane.allowedIPs;
  listenPort = if secretCondition then (import secretPath).wg.listenPort else 0;
  peers = lists.optionals secretCondition (import secretPath).wg.peers;
in
{
  options = {
    modules.services.wireguard.server = {
      enable = mkEnableOption "Enable wireguard.server profile";
    };
  };
  config = mkIf cfg.enable {
    # boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
    environment.systemPackages = [ pkgs.wireguard-tools ];
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    networking.firewall.extraCommands = ''
      iptables -t nat -A POSTROUTING -s10.100.0.0/24 -j MASQUERADE
      iptables -A FORWARD -i wg+ -j ACCEPT
    '';
    networking.firewall.allowedUDPPorts = [ 51820 ];
    networking.firewall.trustedInterfaces = [ "wg0" ];
    networking.wireguard.enable = true;
    networking.wireguard.interfaces = {
      "wg0" = {
        ips = allowedIPs;
        listenPort = listenPort;
        privateKeyFile = "/etc/nixos/secrets/wireguard/private.key";
        peers = peers;
      };
    };
  };
}

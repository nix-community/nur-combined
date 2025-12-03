# Partially based on https://astro.github.io/microvm.nix/simple-network.html
{ config, lib, ... }:
let
  bridge = config.vacu.network.lan_bridge;
  lan_port = "eno1";
in
{
  options = {
    vacu.network.lan_bridge = lib.mkOption {
      type = lib.types.str;
      default = "br-main";
      readOnly = true;
    };
  };
  config = {
    networking.useNetworkd = true;
    systemd.network.enable = true;

    systemd.network.networks."00-lan".extraConfig = ''
      Bridge = ${bridge}

      [Match]
      Name = ${lan_port}
    '';

    systemd.network.netdevs.${bridge} = {
      netdevConfig = {
        Name = bridge;
        Kind = "bridge";
      };
    };

    systemd.network.networks."01-lan-bridge".extraConfig = ''
      DHCP = no
      Address = 172.83.159.53/32
      Address = 10.78.79.237/22
      Gateway = 10.78.79.1
      DNS = 10.78.79.1
      Domains = t2d.lan

      [Match]
      Name = ${bridge}

      [Link]
      RequiredForOnline=routeable
    '';

    systemd.network.networks."10-containers".extraConfig = ''
      Unmanaged = yes

      [Match]
      Name = ve-*
    '';

    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = bridge;
      enableIPv6 = false;
    };
  };
}

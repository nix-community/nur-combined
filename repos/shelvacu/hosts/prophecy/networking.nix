{ config, lib, ... }:
let
  cfg = config.vacu.network;
  bridge = cfg.lan_bridge;
  lan_port = "enx408d5c669f1d";
  lan_route = {
    Gateway = cfg.ips.t2dRouter;
    GatewayOnLink = true;
  };
in
{
  options.vacu.network = {
    lan_bridge = lib.mkOption {
      type = lib.types.str;
      default = "br-main";
      readOnly = true;
    };
    lan_bridge_network = lib.mkOption {
      type = lib.types.str;
      default = "01-lan-bridge";
      readOnly = true;
    };
    ips = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
    };
  };
  config = {
    vacu.network.ips = {
      t2dLANStatic = "10.78.79.22";
      t2dSubnets = [
        "10.78.76.0/22"
        "205.201.63.12/32"
        "172.83.159.53/32"
      ];
      t2dRouter = "10.78.79.1";
    };
    networking.useNetworkd = true;
    systemd.network.enable = true;

    systemd.network.networks."00-lan" = {
      bridge = [ bridge ];
      name = lan_port;
    };

    systemd.network.netdevs.${bridge} = {
      netdevConfig = {
        Name = bridge;
        Kind = "bridge";
      };
    };

    systemd.network.networks.${cfg.lan_bridge_network} = {
      name = bridge;
      DHCP = "no";
      address = [ "${cfg.ips.t2dLANStatic}/22" ];
      routes = [
        lan_route
      ]
      ++ (lib.concatMap (subnet: [
        {
          Scope = "link";
          Destination = subnet;
        }
        {
          Scope = "link";
          Destination = subnet;
          Table = "doofTun";
        }
      ]) cfg.ips.t2dSubnets);
      dns = [ cfg.ips.t2dRouter ];
    };

    systemd.network.networks."10-containers" = {
      linkConfig.Unmanaged = true;
      name = "ve-*";
    };

    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = bridge;
      enableIPv6 = false;
    };
  };
}

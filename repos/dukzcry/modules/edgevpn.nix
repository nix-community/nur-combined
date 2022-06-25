{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.networking.edgevpn;
  server = cfg.enable && cfg.server;
  client = cfg.enable && !cfg.server;
  edgevpn = pkgs.nur.repos.dukzcry.edgevpn;
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
  serviceOptions = pkgs.nur.repos.dukzcry.lib.systemd.default // {
    DeviceAllow = "/dev/net/tun";
    LoadCredential = "config.yaml:${cfg.config}";
  };
  envOptions = {
    IFACE = cfg.interface;
    EDGEVPNLOGLEVEL = cfg.logLevel;
    ADDRESS = ip4.toCIDR cfg.address;
  };
in {
  options.networking.edgevpn = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable EdgeVPN.
      '';
    };
    server = mkEnableOption ''
      server mode
    '';
    logLevel = mkOption {
      type = types.str;
      default = "info";
    };
    config = mkOption {
      type = types.str;
      default = "/etc/edgevpn/config.yaml";
    };
    interface = mkOption {
      type = types.str;
      default = "edgevpn0";
    };
    address = mkOption {
      type = types.anything;
      default = ip4.fromString "10.1.0.1/24";
    };
    dhcp = mkOption {
      type = types.bool;
      default = client;
    };
    router = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    apiPort = mkOption {
      type = types.port;
      default = 8080;
    };
    apiAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
    postStart = mkOption {
      type = types.str;
      default = "";
      example = ''
        ip route add dev ${config.networking.edgevpn.interface} 10.0.0.0/24
        echo -e "nameserver 10.0.0.2\nsearch local" | resolvconf -a ${config.networking.edgevpn.interface}
      '';
    };
    postStop = mkOption {
      type = types.str;
      default = "";
      example = ''
        resolvconf -d ${config.networking.edgevpn.interface}
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [ edgevpn ];
    })
    (mkIf server {
      networking.interfaces.${cfg.interface} = {
        ipv4.addresses = [ (ip4.toNetworkAddress cfg.address) ];
        virtual = true;
        virtualType = "tun";
        virtualOwner = "edgevpn";
      };
      users.groups.edgevpn = {};
      users.users.edgevpn = {
        isSystemUser = true;
        group = "edgevpn";
      };
      systemd.services.edgevpn = {
        requires = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        description = "EdgeVPN server";
        path = with pkgs; [ edgevpn ];
        environment = {
          API = "true";
          APILISTEN = "${cfg.apiAddress}:${toString cfg.apiPort}";
          EDGEVPNBOOTSTRAPIFACE = "false";
        } // envOptions;
        serviceConfig = pkgs.nur.repos.dukzcry.lib.systemd.dynamic // {
          ExecStart = pkgs.writeShellScript "edgevpn" ''
            edgevpn --config $CREDENTIALS_DIRECTORY/config.yaml
          '';
          User = "edgevpn";
          Group = "edgevpn";
          RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK";
        } // serviceOptions;
      };
    })
    (mkIf client {
      boot.kernel.sysctl."net.core.rmem_max" = mkDefault 2500000;
      systemd.services.edgevpn = {
        requires = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];
        description = "EdgeVPN client";
        path = with pkgs; [ edgevpn ];
        environment = {
          DHCPLEASEDIR = "/var/lib/edgevpn";
        } // optionalAttrs cfg.dhcp {
          DHCP = "true";
        } // optionalAttrs (cfg.router != null) {
          ROUTER = cfg.router;
        } // envOptions;
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "edgevpn" ''
            edgevpn --config $CREDENTIALS_DIRECTORY/config.yaml
          '';
          StateDirectory = "edgevpn";
          DynamicUser = true;
          AmbientCapabilities = "CAP_NET_ADMIN";
          CapabilityBoundingSet = "CAP_NET_ADMIN";
          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        } // serviceOptions;
      };
      systemd.services.edgevpn-script = {
        after = [ "sys-devices-virtual-net-${cfg.interface}.device" ];
        bindsTo = [ "sys-devices-virtual-net-${cfg.interface}.device" ];
        wantedBy = [ "sys-devices-virtual-net-${cfg.interface}.device" ];
        description = "EdgeVPN script";
        path = with pkgs; [ iproute2 openresolv ];
        serviceConfig = {
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "edgevpn-start" ''
            ${cfg.postStart}
          '';
          ExecStop = pkgs.writeShellScript "edgevpn-stop" ''
            ${cfg.postStop}
          '';
        };
      };
    })
  ];
}

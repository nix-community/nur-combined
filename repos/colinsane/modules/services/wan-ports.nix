{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.wan-ports;
in
{
  options = with lib; {
    sane.services.wan-ports = {
      openFirewall = mkOption {
        default = false;
        type = types.bool;
      };
      openUpnp = mkOption {
        default = false;
        type = types.bool;
      };
      upnpRenewInterval = mkOption {
        default = "1hr";
        type = types.str;
        description = "how frequently to renew UPnP leases";
      };
      upnpLeaseDuration = mkOption {
        default = 86400;
        type = types.int;
        description = "how long to lease UPnP ports for";
      };

      # TODO: rework this to look like:
      # ports.53 = {
      #   protocol = [ "udp" "tcp" ];  # have this be default
      #   visibility = "wan";  # or "lan"
      # }
      # or maybe:
      # tcp.ports.53 = {
      #   visibility = "wan";  # or "lan"
      # };
      # and a special convertibleTo to handle port ranges
      # plus aggregation to convert individual ports back to ranges before doing certain operations (like UPnP?)
      tcp = mkOption {
        type = types.listOf types.int;
        default = [];
      };
      udp = mkOption {
        type = types.listOf types.int;
        default = [];
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.openFirewall {
      networking.firewall.allowedTCPPorts = cfg.tcp;
      networking.firewall.allowedUDPPorts = cfg.udp;
    })
    (lib.mkIf cfg.openUpnp {
      systemd.services.upnp-forwards = {
        description = "forward ports from upstream gateway to this host";
        serviceConfig.Type = "oneshot";
        restartTriggers = [(builtins.toJSON cfg)];

        after = [ "network.target" ];
        script =
          let
            forwards =
              (builtins.map (p: "tcp:${builtins.toString p}") cfg.tcp) ++
              (builtins.map (p: "udp:${builtins.toString p}") cfg.udp);
          in ''
            ${pkgs.sane-scripts}/bin/sane-ip-port-forward -v -d ${builtins.toString cfg.upnpLeaseDuration} \
              ${builtins.concatStringsSep " " forwards}
          '';
      };

      systemd.timers.upnp-forwards = {
        wantedBy = [ "network.target" ];
        timerConfig = {
          OnStartupSec = "1min";
          OnUnitActiveSec = cfg.upnpRenewInterval;
        };
      };
    })
  ];
}

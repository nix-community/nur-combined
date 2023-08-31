{ config, lib, pkgs, ... }:
let
  cfg = config.sane.ports;

  portOpts = with lib; types.submodule {
    options = {
      protocol = mkOption {
        type = types.listOf (types.enum [ "udp" "tcp" ]);
      };
      visibleTo.lan = mkOption {
        type = types.bool;
        default = false;
        # XXX: if a service is visible to the WAN, it ends up visible to the LAN as well.
        # technically solvable  (explicitly drop packets delivered from LAN IPs) but doesn't make much sense.
      };
      visibleTo.wan = mkOption {
        type = types.bool;
        default = false;
      };
      visibleTo.ovpn = mkOption {
        type = types.bool;
        default = false;
        # XXX: behaves more or less the same as `lan` visibility.
        # OVPN passes everything by default.
        # TODO: have *this* drive what we forward from wireguard namespace to main namespace
      };
      description = mkOption {
        type = types.str;
        default = "colin-${config.net.hostName}";
        description = ''
          short description of why this port is open.
          this is shown, for example, in an upstream's UPnP status page.
        '';
      };
    };
  };

  # gives networking.firewall value for a given "${port}" = portCfg.
  firewallConfigForPort = port: portCfg:
    # any form of visibility means we need to open the firewall
    lib.mkIf (portCfg.visibleTo.lan || portCfg.visibleTo.wan || portCfg.visibleTo.ovpn) {
      allowedTCPPorts = lib.optional (lib.elem "tcp" portCfg.protocol) (lib.toInt port);
      allowedUDPPorts = lib.optional (lib.elem "udp" portCfg.protocol) (lib.toInt port);
    };

  upnpServiceForPort = port: portCfg:
    lib.mkIf portCfg.visibleTo.wan {
      "upnp-forward-${port}" = {
        description = "forward port ${port} (${portCfg.description}) from upstream gateway to this host";
        restartTriggers = [(builtins.toJSON portCfg)];

        serviceConfig = {
          Type = "oneshot";
          TimeoutSec = "6min";
          ExecStart =
          let
            portFwd = "${pkgs.sane-scripts.ip-port-forward}/bin/sane-ip-port-forward";
            forwards = lib.flatten [
              (lib.optional (lib.elem "udp" portCfg.protocol) "udp:${port}:${portCfg.description}")
              (lib.optional (lib.elem "tcp" portCfg.protocol) "tcp:${port}:${portCfg.description}")
            ];
          in ''
            ${portFwd} -v -d ${builtins.toString cfg.upnpLeaseDuration} \
              ${lib.escapeShellArgs forwards}
          '';
        };

        after = [ "network.target" ];
        wantedBy = [ "upnp-forwards.target" ];
      };
    };
in
{
  options = with lib; {
    sane.ports = {
      openFirewall = mkOption {
        default = false;
        type = types.bool;
      };
      openUpnp = mkOption {
        default = false;
        type = types.bool;
      };
      upnpRenewInterval = mkOption {
        default = "hourly";
        type = types.str;
        description = ''
          how frequently to renew UPnP leases.
          syntax is what systemd uses for Calendar Events:
          - <https://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events>
        '';
      };
      upnpLeaseDuration = mkOption {
        default = 86400;
        type = types.int;
        description = "how long to lease UPnP ports for";
      };

      ports = mkOption {
        type = types.attrsOf portOpts;
        default = {};
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.openFirewall {
      networking.firewall = lib.mkMerge (lib.mapAttrsToList firewallConfigForPort cfg.ports);
    })
    (lib.mkIf cfg.openUpnp {
      systemd.services = lib.mkMerge (lib.mapAttrsToList upnpServiceForPort cfg.ports);
      # in order to run all upnp-forward-xyz services on a regular schedule:
      # - upnp-forwards.timer
      #   -> activates upnp-forwards.target
      #      -> activates all upnp-forward-xyz.service's
      #
      # crucially, the timer only activates the target if upnp-forwards.target is in the "stopped" (or, "inactive") state.
      # this isn't the case by default. but adding `StopWhenUnneeded` to the target causes it to be considered "stopped"
      # immediately after it schedules the services.
      #
      # additionally, one could add `Upholds = upnp-forwards.target` to all the services if we only want the target to
      # be stopped after all forwards are complete.
      # source: <https://serverfault.com/a/1128671>
      systemd.timers.upnp-forwards = {
        wantedBy = [ "network.target" ];
        timerConfig = {
          OnStartupSec = "75s";
          OnCalendar = cfg.upnpRenewInterval;
          RandomizeDelaySec = "30s";
          Unit = "upnp-forwards.target";
        };
      };
      systemd.targets.upnp-forwards = {
        description = "forward ports from upstream gateway to this host";
        after = [ "network.target" ];
        unitConfig = {
          StopWhenUnneeded = true;
        };
      };
    })
  ];
}

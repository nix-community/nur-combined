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
        description = "forward port ${port} from upstream gateway to this host";
        serviceConfig.Type = "oneshot";
        restartTriggers = [(builtins.toJSON portCfg)];

        after = [ "network.target" ];
        wantedBy = [ "upnp-forwards.target" ];
        script =
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
        default = "1hr";
        type = types.str;
        description = "how frequently to renew UPnP leases";
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
      systemd.timers.upnp-forwards = {
        wantedBy = [ "network.target" ];
        timerConfig = {
          OnStartupSec = "1min";
          OnUnitActiveSec = cfg.upnpRenewInterval;
          Unit = "upnp-forwards.target";
        };
      };
      systemd.targets.upnp-forwards = {
        description = "forward ports from upstream gateway to this host";
        after = [ "network.target" ];
      };
    })
  ];
}

{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.sane.services.dyn-dns;
  # getIp = pkgs.writeShellScript "dyn-dns-query-wan" ''
  #   # preferred method and fallback
  #   # OPNsense router broadcasts its UPnP endpoint every 30s
  #   timeout 60 ${lib.getExe pkgs.sane-scripts.ip-check} --json || \
  #     ${lib.getExe pkgs.sane-scripts.ip-check} --json --no-upnp
  # '';
  getIp = "${lib.getExe pkgs.sane-scripts.ip-check} --json";
in
{
  options = {
    sane.services.dyn-dns = {
      enable = mkEnableOption "keep track of the public WAN address of this machine, as viewed externally";

      ipPath = mkOption {
        default = "/var/lib/dyn-dns/wan.txt";
        type = types.str;
        description = "where to store the latest WAN IPv4 address";
      };

      upnpPath = mkOption {
        default = "/var/lib/dyn-dns/upnp.txt";
        type = types.str;
        description = ''
          where to store the address of the UPNP device (if any) that can be used to create port forwards.
        '';
      };

      ipCmd = mkOption {
        default = getIp;
        defaultText = "path/to/sane-ip-check --json";
        type = types.path;
        description = "command to run to query the current WAN IP";
      };

      interval = mkOption {
        type = types.str;
        default = "10min";
        description = "systemd time string for how frequently to re-check the IP";
      };

      restartOnChange = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "list of systemd units to restart when the IP changes";
      };
      requireForStart = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "list of systemd units that should not be started until after we know an IP";
      };
    };
  };

  config = mkIf cfg.enable {
    sane.persist.sys.byStore.plaintext = [
      { user = "root"; group = "root"; mode = "0755"; path = "/var/lib/dyn-dns"; method = "bind"; }
    ];
    systemd.services.dyn-dns = {
      description = "update this host's record of its WAN IP";
      serviceConfig.Type = "oneshot";
      restartTriggers = [(builtins.toJSON cfg)];

      after = [ "network.target" ];

      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = "60s";
      # XXX(2024-11-11): OPNsense *used* to broadcast its UPnP endpoint every 30s; now it's every 5-10m!
      serviceConfig.TimeoutStartSec = "600s";

      script = let
        jq = lib.getExe pkgs.jq;
      in ''
        set -e
        mkdir -p "$(dirname '${cfg.ipPath}')"
        mkdir -p "$(dirname '${cfg.upnpPath}')"
        newIpDetails=$(${cfg.ipCmd})
        newIp=$(echo "$newIpDetails" | ${jq} -r ".wan")
        newUpnp=$(echo "$newIpDetails" | ${jq} -r ".upnp")
        oldIp=$(cat '${cfg.ipPath}' || echo)
        oldUpnp=$(cat '${cfg.upnpPath}' || echo)

        # systemd path units are triggered on any file write action,
        # regardless of content change. so only update the file if our IP *actually* changed
        if [[ -n "$newIp" && "$newIp" != "$oldIp" ]]; then
          echo "$newIp" > '${cfg.ipPath}'
          echo "WAN ip changed $oldIp -> $newIp"
        fi

        if [[ -n "$newUpnp" && "$newUpnp" != "$oldUpnp" ]]; then
          echo "$newUpnp" > '${cfg.upnpPath}'
          echo "UPNP changed $oldUpnp -> $newUpnp"
        fi

        [[ -f '${cfg.ipPath}' && -f '${cfg.upnpPath}' ]]
      '';
    };

    systemd.timers.dyn-dns = {
      wantedBy = [ "dyn-dns.service" ];
      timerConfig.OnUnitInactiveSec = cfg.interval;
    };

    systemd.targets.dyn-dns-exists = {
      # consumers depend directly on this target for permission to *start*
      # once active, this target should never de-activate
      description = "initial acquisition of dynamic DNS data";
      wants = [ "dyn-dns.service" ];
      after = [ "dyn-dns.service" ];
      wantedBy = cfg.requireForStart;
      before = cfg.requireForStart;  # prevent user service from starting until after we have dyn dns
    };

    systemd.targets.dyn-dns-events = {
      # consumers depend on this to be restarted whenever DNS changes (after acquisition)
      description = "event system that notifies via restart whenever dynamic DNS mapping changes";
      requiredBy = cfg.restartOnChange;  # this just propagates the restart events to the user service
    };

    systemd.paths.dyn-dns-changed = {
      wantedBy = cfg.restartOnChange;
      wants = [ "dyn-dns.service" ];
      before = [
        "dyn-dns.service"
        "dyn-dns-events.target"
      ];
      pathConfig.PathChanged = [ cfg.ipPath ];
    };
    systemd.services.dyn-dns-changed = {
      description = "dynamic DNS change notifier";
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = "${lib.getExe' pkgs.systemd "systemctl"} restart dyn-dns-events.target";
    };
  };
}

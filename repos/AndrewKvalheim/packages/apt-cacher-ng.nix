{ config, lib, pkgs, ... }:

let
  inherit (lib) getExe mkEnableOption mkIf mkMerge mkOption;
  inherit (lib.types) int;
  inherit (pkgs) apt-cacher-ng writeShellScript;

  cfg = config.services.apt-cacher-ng;

  mkService =
    let
      base = {
        after = [ "network.target" ];

        serviceConfig = {
          DynamicUser = true;
          CacheDirectory = "%N";
          RuntimeDirectory = "%N";
          WorkingDirectory = "/run/apt-cacher-ng";
          IPAccounting = true;

          CapabilityBoundingSet = "";
          DevicePolicy = "closed";
          IPAddressDeny = [ "link-local" "multicast" ];
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
          UMask = "0077";

          CPUSchedulingPolicy = "batch";
          IOSchedulingClass = "idle";
        };
      };
    in
    overlay: mkMerge [ base overlay ];
in
{
  options.services.apt-cacher-ng = {
    enable = mkEnableOption "caching proxy of APT repositories";
    port = mkOption { type = int; default = 3142; };
  };

  config = mkIf cfg.enable {
    systemd.services.apt-cacher-ng = mkService {
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = writeShellScript "capture-logs" ''
          touch $RUNTIME_DIRECTORY/apt-cacher.dbg
          systemd-cat --identifier 'apt-cacher-ng' --priority 'debug' \
            tail --follow --lines 0 --quiet \
              $RUNTIME_DIRECTORY/apt-cacher.dbg \
          &

          touch $RUNTIME_DIRECTORY/apt-cacher.err
          systemd-cat --identifier 'apt-cacher-ng' --priority 'debug' \
            tail --follow --lines 0 --quiet \
              $RUNTIME_DIRECTORY/apt-cacher.err \
          &

          touch $RUNTIME_DIRECTORY/apt-cacher.log
          systemd-cat --identifier 'apt-cacher-ng' --priority 'info' \
            tail --follow --lines 0 --quiet \
              $RUNTIME_DIRECTORY/apt-cacher.log \
          &

          ${getExe apt-cacher-ng} -v \
            CacheDir=$CACHE_DIRECTORY \
            LogDir=$RUNTIME_DIRECTORY \
            UnbufferLogs=1 \
            Port=${toString cfg.port} \
            ForeGround=1 \
            ReportPage=acng-report.html \
          &

          wait
        '';
      };
    };

    systemd.services.apt-cacher-ng-maintenance = mkService {
      startAt = "07:00 America/Los_Angeles";

      serviceConfig = {
        Type = "oneshot";
        ExecCondition = writeShellScript "is-power-unlimited" ''
          case "$(< /sys/class/power_supply/AC/online)" in
            0) exit 1;;
            1) exit 0;;
            *) exit 255;;
          esac
        '';
        ExecStart = ''
          ${apt-cacher-ng}/lib/apt-cacher-ng/acngtool maint \
            Port=${toString cfg.port}
        '';
      };
    };

    systemd.timers.apt-cacher-ng-maintenance.timerConfig.Persistent = true;
  };
}

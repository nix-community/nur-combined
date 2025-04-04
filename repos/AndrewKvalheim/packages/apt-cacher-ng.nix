{ config, lib, pkgs, ... }:

let
  inherit (lib) escapeShellArg getExe getExe' mkEnableOption mkIf mkMerge mkOption;
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
        ExecStart = writeShellScript "apt-cacher-ng-journaled" ''
          journal() { touch "$3"; exec systemd-cat --identifier "$1" --priority "$2" tail --follow --quiet "$3"; }

          journal 'apt-cacher-ng' 'debug' "$RUNTIME_DIRECTORY/apt-cacher.err" &
          journal 'apt-cacher-ng' 'info' "$RUNTIME_DIRECTORY/apt-cacher.log" &

          exec ${getExe apt-cacher-ng} -v \
            CacheDir="$CACHE_DIRECTORY" \
            LogDir="$RUNTIME_DIRECTORY" \
            UnbufferLogs='1' \
            Port=${escapeShellArg cfg.port} \
            ForeGround='1' \
            ReportPage='acng-report.html'
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
          ${getExe' apt-cacher-ng "acngtool"} maint \
            Port=${escapeShellArg cfg.port}
        '';
      };
    };

    systemd.timers.apt-cacher-ng-maintenance.timerConfig.Persistent = true;
  };
}

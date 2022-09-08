{ pkgs, osConfig ? { }, config, lib, ... }: with lib; let
  cfg = config.services.watchdogs;
  services = filterAttrs (_: wd: wd.enable) cfg.services;
  arclib = import ../../lib { inherit lib; };
  unmerged = lib.unmerged or arclib.unmerged;
  systemd = osConfig.systemd.package or pkgs.systemd;
  canRequire = false;
  package = pkgs.writeShellScriptBin "watchdog-command" ''
    while ${pkgs.coreutils}/bin/sleep $((WATCHDOG_USEC / 2000000)); do
      if "$@" > /dev/null; then
        ${systemd}/bin/systemd-notify WATCHDOG=1
      else
        echo tripped >&2
      fi
    done
  '';
  watchdogModule = { config, name, ... }: {
    options = {
      enable = mkEnableOption "watchdog" // {
        default = true;
      };
      name = mkOption {
        type = types.str;
        default = name + "-watchdog";
      };
      service = mkOption {
        type = unmerged.type;
      };
      target = mkOption {
        type = types.str;
      };
      command = mkOption {
        type = with types; listOf str;
      };
      interval = mkOption {
        type = types.str;
        default = "90s";
      };
    };
    config = {
      service = rec {
        Install = mkIf canRequire {
          RequiredBy = Unit.After;
        };
        Unit = {
          After = [ config.target ];
          BindsTo = Unit.After;
        };
        Service = {
          WatchdogSec = config.interval;
          WatchdogSignal = "SIGTERM";
          NotifyAccess = "all";
          ExecStart = "${getExe cfg.package} ${escapeShellArgs config.command}";
          Nice = 10;
        };
      };
    };
  };
in {
  options.services.watchdogs = {
    enable = mkEnableOption "watchdogs" // {
      default = cfg.services != { };
    };
    package = mkOption {
      type = types.package;
      default = package;
    };
    services = mkOption {
      type = with types; attrsOf (submodule watchdogModule);
      default = { };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = mapAttrs' (_: wd: nameValuePair wd.name (unmerged.merge wd.service)) services;
    systemd.user.targets = mkMerge (mapAttrsToList (_: wd: {
      ${removeSuffix ".target" wd.target}.Unit = {
        Requires = mkIf (!canRequire) [ "${wd.name}.service" ];
        BindsTo = [ "${wd.name}.service" ];
      };
    }) services);
  };
}

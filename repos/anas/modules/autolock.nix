{ config, lib, pkgs, ... }:

let
  cfg = config.services.autolock;

  optionalArg = flag: value:
    lib.optionals (value != null && value != "") [
      flag
      value
    ];

  args =
    lib.concatLists [
      (optionalArg "-t" cfg.timeout)
      (optionalArg "-i" cfg.interval)
      (optionalArg "-c" cfg.lockCommand)
      (optionalArg "-f" cfg.fullscreenTimeout)
      (lib.optional cfg.ignoreSleep "--ignore-sleep")
      cfg.extraArgs
    ];
in {
  options.services.autolock = {
    enable = lib.mkEnableOption "autolock";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.autolock;
    };

    display = lib.mkOption {
      type = lib.types.str;
      default = "";
    };

    timeout = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Timeout in seconds.";
    };

    interval = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Interval time in seconds.";
    };

    lockCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Command to execute when locking.";
    };

    fullscreenTimeout = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Fullscreen timeout in seconds.";
    };

    ignoreSleep = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Ignore the sleep signal.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.autolock = {
    #systemd.services.autolock = {
      Unit = {
        Description = "A minimal X11 idle-watcher";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = lib.escapeShellArgs (
          [ "${cfg.package}/bin/autolock" ] ++ args
        );

        Restart = "on-failure";
        
        Environment = lib.optional (
          cfg.display != ""
        ) "DISPLAY=${cfg.display}";
      };
        

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

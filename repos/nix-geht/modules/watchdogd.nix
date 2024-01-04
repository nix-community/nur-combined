{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.watchdogd;

  mkPluginOpts = plugin: defWarn: defCrit: {
    enable = mkEnableOption "watchdogd plugin ${plugin}";
    interval = mkOption {
      type = types.ints.unsigned;
      default = 300;
      description = ''
        Amount of seconds between every poll.
      '';
    };
    logmark = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to log current stats every poll interval.
      '';
    };
    warning = mkOption {
      type = types.numbers.nonnegative;
      description = ''
        The high watermark level. Alert sent to log.
      '';
    } // optionalAttrs (defWarn != null) {
      default = defWarn;
    };
    critical = mkOption {
      type = types.numbers.nonnegative;
      default = defCrit;
      description = ''
        The critical watermark level. Alert sent to log, followed by reboot or script action.
      '';
    } // optionalAttrs (defCrit != null) {
      default = defCrit;
    };
  };
in {
  options.services.watchdogd = {
    enable = mkEnableOption "watchdogd, an advanced system & process supervisor";
    package = mkOption {
      default = pkgs.callPackage ../pkgs/troglobit/watchdogd.nix {};
      defaultText = "pkgs.watchdogd";
      type = types.package;
      description = "watchdogd package to use";
    };

    timeout = mkOption {
      type = types.ints.unsigned;
      default = 15;
      description = ''
        The WDT timeout before reset.
      '';
    };
    interval = mkOption {
      type = types.ints.unsigned;
      default = 5;
      description = ''
        The kick interval, i.e. how often {manpage}`watchdogd(8)` should reset the WDT timer.
      '';
    };

    safeExit = mkOption {
      type = types.bool;
      default = true;
      description = ''
        With {var}`safeExit` enabled, the daemon will ask the driver to disable the WDT before exiting.
        However, some WDT drivers (or hardware) may not support this.
      '';
    };

    extraConfig = mkOption {
      type = with types; nullOr lines;
      default = null;
      description = ''
        Additional config to put in {file}`watchdogd.conf`.
        See {manpage}`watchdogd.conf(5)` for syntax.
     '';
    };

    filenr = mkPluginOpts "filenr" 0.9 1.0;
    loadavg = mkPluginOpts "loadavg" null null;
    meminfo = mkPluginOpts "meminfo" 0.9 0.95;
  };

  config = let
    mkPluginConf = plugin:
      let pcfg = cfg.${plugin};
      in optionalString pcfg.enable ''
        ${plugin} {
          enabled  = true
          interval = ${toString pcfg.interval}
          logmark  = ${toString pcfg.logmark}
          warning  = ${toString pcfg.warning}
          critical = ${toString pcfg.critical}
        }
    '';
    watchdogdConf = pkgs.writeText "watchdogd.conf" ''
      timeout = ${toString cfg.timeout}
      interval = ${toString cfg.interval}
      safe-exit = ${boolToString cfg.safeExit}
      ${mkPluginConf "filenr"}
      ${mkPluginConf "loadavg"}
      ${mkPluginConf "meminfo"}
      ${optionalString (cfg.extraConfig != null) cfg.extraConfig}
    '';
  in mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Create the service.
    systemd.services.watchdogd = {
      documentation = [
        "man:watchdogd(8)"
        "man:watchdogd.conf(5)"
      ];
      wantedBy = [ "multi-user.target" ];
      description = "Advanced system & process supervisor";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/watchdogd -n -f ${watchdogdConf}";
      };
    };
  };
}

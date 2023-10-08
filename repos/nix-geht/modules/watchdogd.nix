{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.watchdogd;

  mkPluginOpts = plugin: {
    enable = mkEnableOption "watchdogd plugin ${plugin}";
    interval = mkOption {
      type = types.int;
      default = 300;
      description = ''
        The poll interval. Defaults to 300 seconds.
      '';
    };
    logmark = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Log current stats every poll interval.
        Defaults to disabled.
      '';
    };
    warning = mkOption {
      type = types.int;
      description = ''
        The high watermark level. Alert sent to log.
      '';
    };
    critical = mkOption {
      type = types.int;
      description = ''
        The critical watermark level. Alert sent to log, followed by reboot or script action.
      '';
    };
  };

  mkPluginConf = plugin: let
    pcfg = cfg.${plugin};
  in
    optionalString pcfg.enable ''

      ${plugin} {
        enabled  = true
        interval = ${toString pcfg.interval}
        logmark  = ${toString pcfg.logmark}
        warning  = ${toString pcfg.warning}
        critical = ${toString pcfg.critical}
      }
    '';
in {
  options.services.watchdogd = {
    enable = mkEnableOption "Advanced system & process supervisor";
    package = mkOption {
      default = pkgs.callPackage ../pkgs/troglobit/watchdogd.nix {};
      defaultText = "pkgs.watchdogd";
      type = types.package;
      description = "watchdogd package to use";
    };

    timeout = mkOption {
      type = types.int;
      default = 15;
      description = ''
        The WDT timeout before reset.
        Defaults to 15 seconds.
      '';
    };
    interval = mkOption {
      type = types.int;
      default = 5;
      description = ''
        The kick interval, i.e. how often watchdogd(8) should reset the WDT timer.
        Defaults to 5 seconds.
      '';
    };

    safeExit = mkOption {
      type = types.bool;
      default = true;
      description = ''
        With safeExit enabled, the daemon will ask the driver to disable the WDT before exiting.
        However, some WDT drivers (or HW) may not support this
        Defaults to true.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Additional config to put in watchdogd.conf.
        See watchdogd.conf(5) for syntax.
      '';
    };

    filenr = mkPluginOpts "filenr";
    loadavg = mkPluginOpts "loadavg";
    meminfo = mkPluginOpts "meminfo";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    # Create the service.
    systemd.services.watchdogd = {
      wantedBy = ["multi-user.target"];
      description = "Advanced system & process supervisor";
      path = [cfg.package];
      restartTriggers = [config.environment.etc."watchdogd.conf".source];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/watchdogd -n -f /etc/watchdogd.conf";
      };
    };

    # Write the config.
    environment.etc."watchdogd.conf" = {
      enable = true;
      mode = "0644";
      text =
        ''
          timeout = ${toString cfg.timeout}
          interval = ${toString cfg.interval}
          safe-exit = ${boolToString cfg.safeExit}
        ''
        + mkPluginConf "filenr"
        + mkPluginConf "loadavg"
        + mkPluginConf "meminfo";
    };
  };
}

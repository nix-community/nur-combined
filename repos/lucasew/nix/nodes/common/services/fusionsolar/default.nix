{ config, lib, pkgs, ...}:

let
  inherit (lib) mkOption mkEnableOption types mkIf;
  cfg = config.services.fusionsolar-reporter;
  python = pkgs.python3.withPackages (p: with p; [
    selenium
  ]);
in

{
  options.services.fusionsolar-reporter = {
    enable = mkEnableOption "fusionsolar-reporter";

    environmentFile = mkOption {
      type = types.path;
      example = "/var/run/secrets/fusionsolar";
      default = "/var/run/secrets/fusionsolar";
      description = "Credentials file";
    };

    user = mkOption {
      type = types.str;
      default = "fusionsolar";
    };

    group = mkOption {
      type = types.str;
      default = "fusionsolar";
    };

    calendar = mkOption {
      type = types.str;
      default = "20:00:01";
      description = "When to run the report";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."fusionsolar" = {
      sopsFile = ../../../../secrets/fusionsolar.env;
      format = "dotenv";
    };
    systemd.timers.fusionsolar-reporter = {
      description = "Fusionsolar reporter timer";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.calendar;
        AccuracySec = "30m";
        Unit = "fusionsolar-reporter.service";
      };
    };
    systemd.services.fusionsolar-reporter = {
      enable = true;
      path = with pkgs; [ chromedriver chromium ];
      requires = ["network-online.target"];
      serviceConfig = {
        EnvironmentFile = cfg.environmentFile;
        DynamicUser = true;
        User = cfg.user;
        Group = cfg.group;
      };
      script = ''
        exec ${lib.getExe pkgs.xvfb-run} ${python.interpreter} ${./payload.py}
      '';
    };
  };
}

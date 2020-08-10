{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.services.import-garmin-connect;

  profileConfig = types.submodule {
    options = {
      username = mkOption {
        type = types.str;
        description = "Username";
      };

      passwordFile = mkOption {
        type = types.str;
        description = "Password file";
      };

      profile = mkOption {
        type = types.str;
        description = "Profile name";
      };
    };
  };

  script = cfg: profile: pkgs.writeShellScriptBin "run" ''
    ${pkgs.import-garmin-connect}/bin/import-garmin-connect \
      --user ${profile.username} \
      --password $(cat ${profile.passwordFile}) \
      --profile ${profile.profile} \
      --influx-host ${cfg.influx.host} \
      --influx-port ${toString cfg.influx.port} \
      --influx-db ${cfg.influx.db} \
      --date $(date --date="-1 day" +'%Y-%m-%d') \
      --days 2
  '';
in

{

  options.services.import-garmin-connect = {
    enable = mkEnableOption "Import Garmin Connect";

    profiles = mkOption {
      type = types.attrsOf profileConfig;
      description = "Profiles";
    };

    influx = {
      host = mkOption {
        type = types.str;
        default = "localhost";
        example = "127.0.0.1";
      };

      port = mkOption {
        type = types.int;
        default = 8086;
      };

      db = mkOption {
        type = types.str;
        default = "garmin";
      };
    };

    interval = mkOption {
      type = types.str;
      default = "hourly";
      description = "OnCalendar specification";
    };

    onFailure = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Start this service if an import fails.";
      example = "notify-failed@%n";
    };
  };

  config = mkIf cfg.enable {
    # Define a service per profile.
    systemd.services = flip mapAttrs' cfg.profiles (name: profile:
      nameValuePair "import-garmin-connect-${name}" {
        description = "Import Garmin Connect for profile ${name}";
        onFailure = if isNull cfg.onFailure  then [] else [cfg.onFailure];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${script cfg profile}/bin/run";
        };
      });

    # Define a timer for each job.
    systemd.timers = flip mapAttrs' cfg.profiles (name: value:
      nameValuePair "import-garmin-connect-${name}" {
        description = "Timer for importing Garmin Connect of profile ${name}";
        partOf = ["import-garmin-connect-${name}.service"];
        wantedBy = ["timers.target"];
        timerConfig.OnCalendar = cfg.interval;
      });
  };

}

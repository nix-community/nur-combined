{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.services.solaredge-influx;

  exportSettings = cfg: ''
    export SOLAREDGE_API_KEY="$(cat ${cfg.apiKeyFile})"
    export SOLAREDGE_SITE_ID=${toString cfg.siteId}
    export INFLUX_HOST="${cfg.influx.host}"
    export INFLUX_PORT=${toString cfg.influx.port}
    export INFLUX_DB="${cfg.influx.db}"
  '';

  script = cfg: name: command: pkgs.writeShellScript name ''
    ${exportSettings cfg}
    ${pkgs.solaredge-influx}/bin/solaredge-influx ${command}
  '';

  versionCheck = cfg: script cfg "solaredge-version-check" "version";

  importPower = cfg: script cfg "solaredge-power"
    "power --minutes ${toString cfg.power.period}";

  importInverter = cfg: script cfg "solaredge-inverter"
    "inverter --serial ${cfg.inverter.serial} --minutes ${toString cfg.inverter.period}";

  importEnergy = cfg: script cfg "solaredge-energy"
    "energy --minutes ${toString cfg.energy.period}";

in

{

  options.services.solaredge-influx = {
    enable = mkEnableOption "Import Solaredge data into InfluxDB";

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
        default = "power";
      };
    };

    versionCheck = {
      interval = mkOption {
        type = types.str;
        default = "daily";
        description = "OnCalendar specification";
      };
    };

    power = {
      interval = mkOption {
        type = types.str;
        default = "15min";
        description = "OnUnitActiveSec specification";
      };

      period = mkOption {
        type = types.int;
        default = 60;
        description = "Period to scrape in minutes";
      };
    };

    energy = {
      interval = mkOption {
        type = types.str;
        default = "15min";
        description = "OnUnitActiveSec specification";
      };

      period = mkOption {
        type = types.int;
        default = 60;
        description = "Period to scrape in minutes";
      };
    };

    inverter = {
      serial = mkOption {
        type = types.str;
        description = "Serial number of the inverter";
      };

      interval = mkOption {
        type = types.str;
        default = "60min";
        description = "OnUnitActiveSec specification";
      };

      period = mkOption {
        type = types.int;
        default = 120;
        description = "Period to scrape in minutes";
      };
    };

    siteId = mkOption {
      type = types.int;
      description = "Solaredge site id";
    };

    apiKeyFile = mkOption {
      type = types.str;
      description = "File path to the API key";
    };

    onFailure = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Start this service if an import fails.";
      example = "notify-failed@%n";
    };
  };

  config = mkIf cfg.enable {
    systemd.services = {
      solaredge-version-check = {
        description = "Solaredge monitoring API version check";
        onFailure = if isNull cfg.onFailure  then [] else [cfg.onFailure];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = versionCheck cfg;
        };
      };

      solaredge-import-power = {
        description = "Solaredge import power data to InfluxDB";
        onFailure = if isNull cfg.onFailure  then [] else [cfg.onFailure];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = importPower cfg;
        };
      };

      solaredge-import-inverter = {
        description = "Solaredge import inverter data to InfluxDB";
        onFailure = if isNull cfg.onFailure  then [] else [cfg.onFailure];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = importInverter cfg;
        };
      };

      solaredge-import-energy = {
        description = "Solaredge import energy data to InfluxDB";
        onFailure = if isNull cfg.onFailure  then [] else [cfg.onFailure];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = importEnergy cfg;
        };
      };
    };

    systemd.timers = {
      solaredge-version-check = {
        description = "Timer for Solaredge monitoring API version check";
        partOf = ["solaredge-version-check.service"];
        wantedBy = ["timers.target"];
        timerConfig.OnCalendar = cfg.versionCheck.interval;
      };

      solaredge-import-power = {
        description = "Timer for Solaredge import power data";
        partOf = ["solaredge-import-power.service"];
        wantedBy = ["timers.target"];
        timerConfig.OnBootSec = "5m";
        timerConfig.OnUnitActiveSec = cfg.power.interval;
      };

      solaredge-import-inverter = {
        description = "Timer for Solaredge import inverter data";
        partOf = ["solaredge-import-inverter.service"];
        wantedBy = ["timers.target"];
        timerConfig.OnBootSec = "15m";
        timerConfig.OnUnitActiveSec = cfg.inverter.interval;
      };

      solaredge-import-energy = {
        description = "Timer for Solaredge import energy data";
        partOf = ["solaredge-import-energy.service"];
        wantedBy = ["timers.target"];
        timerConfig.OnBootSec = "1m";
        timerConfig.OnUnitActiveSec = cfg.energy.interval;
      };
    };
  };

}

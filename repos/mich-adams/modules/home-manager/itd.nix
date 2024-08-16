{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.itd;
  tomlFormat = pkgs.formats.toml { };
in {
  #meta.maintainers = [ ];

  options.services.itd = {
    enable = mkEnableOption "itd";

    package = mkOption {
      type = types.package;
      default = pkgs.itd;
      description = "Package providing itd";
    };

    device = mkOption {
      type = types.str;
      default = null;
      description = "mac address of infinitime";
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = {
        bluetooth.adapter = "hci0";
        socket.path = "/tmp/itd/socket";
        metrics = {
          enabled = true;
          heartRate.enabled = true;
          stepCount.enabled = true;
          battLevel.enabled = true;
          motion.enabled = false; # This may lower the battery life of the PineTime
        };
        conn = {
          reconnect = true;
          whitelist = {
            enabled = false;
            devices = [ cfg.device ];
          };
        };
        on.connect.notify = false;
        on.reconnect = {
          notify = false;
          setTime = true;
        };
        notifs = {
          translit.use = [ "eASCII" "Emoji" ];
          ignore = {
            sender = [];
            summary = ["InfiniTime"];
            body = [];
          };
        };
        music.vol.interval = 5;
        weather = {
          enabled = false;
          location = "";
        };
        logging.level = "info";
      };
      description = ''
          Configuration written to {file}`$XDG_CONFIG_HOME/itd.toml`.
      '';
    };
  };

  config = mkIf cfg.enable {

    home.packages = [ cfg.package ];

    xdg.configFile."itd.toml".source = tomlFormat.generate "itd.toml" cfg.settings;

    systemd.user.services.itd = {
      Unit = {
        Description = "InfiniTime Daemon (itd)";
        After = [ "bluetooth.target" ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/itd";
        Restart = "always";
        StandardOutput = "journal";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}


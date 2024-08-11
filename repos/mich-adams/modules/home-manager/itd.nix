{ config, lib, pkgs, ... }:

with lib;

let
  serviceConfig = config.services.itd;
  tomlFormat = pkgs.formats.toml { };
in {
  meta.maintainers = [ maintainers.mich-adams ];

  options = {
    services.itd = {
      enable = mkEnableOption "itd service";

      settings = lib.mkoption {
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
              devices = [];
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

    config = mkIf serviceConfig.enable {
      assertions = [
        (lib.hm.assertions.assertPlatform "services.itd" pkgs
        lib.platforms.linux)
      ];

      home.packages = [ pkgs.itd ];

      xdg.configFile."itd.toml" = lib.mkIf (serviceConfig.settings != { }) {
        source = tomlFormat.generate "itd.toml" serviceConfig.settings;
      };

      systemd.user = {
        services.itd = {
          Unit = {
            Description = "InfiniTime Daemon (itd)";
            After = [ "bluetooth.target" ];
          };
          Service = {
            ExecStart = "${pkgs.itd}/bin/itd";
            Restart = "always";
            StandardOutput = "journal";
          };
          Install = { WantedBy = [ "default.target" ]; };
        };

      };
    };
  }

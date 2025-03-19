{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.itd;
  tomlFormat = pkgs.formats.toml { };
in
{
  #meta.maintainers = [ ];

  options.services.itd = {
    enable = mkEnableOption "itd";

    user = mkOption {
      type = types.str;
      default = null;
      description = "User to install systemd service file under";
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
          translit.use = [
            "eASCII"
            "Emoji"
          ];
          ignore = {
            sender = [ ];
            summary = [ "InfiniTime" ];
            body = [ ];
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
        Configuration written to {file}`/etc/itd.toml`.
      '';
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.itd ];

    environment.etc."itd.toml".source = tomlFormat.generate "itd.toml" cfg.settings;

    systemd.user.services.itd = {
      unitConfig = {
        Description = "InfiniTime Daemon (itd)";
        After = [ "bluetooth.target" ];
      };
      serviceConfig = {
        ExecStart = "${pkgs.itd}/bin/itd";
        Restart = "always";
        StandardOutput = "journal";
      };
      wantedBy = [ "default.target" ];
    };

  };
}

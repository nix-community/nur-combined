{ pkgs, options, config, lib, ... }: with lib; let
  cfg = config.services.systemd2mqtt;
  hasHostname = config.networking.hostName != "";
  StateDirectory = "systemd2mqtt";
  WorkingDirectory = "/var/lib/${StateDirectory}";
in {
  options.services.systemd2mqtt = {
    enable = mkEnableOption "systemd2mqtt";
    units = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    mqtt = {
      url = mkOption {
        type = types.nullOr types.str;
      };
      clientId = mkOption {
        type = types.str;
        default = "systemd" + optionalString hasHostname "-${config.networking.hostName}";
      };
      username = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
    createUser = mkOption {
      type = types.bool;
      default = cfg.user == "systemd2mqtt";
    };
    user = mkOption {
      type = types.str;
      default = "systemd2mqtt";
    };
    package = mkOption {
      type = types.package;
    };
  };
  config = mkMerge [ {
    services.systemd2mqtt.package = mkIf (pkgs ? systemd2mqtt) (mkOptionDefault pkgs.systemd2mqtt);
  } (mkIf cfg.enable {
    systemd.services.systemd2mqtt = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "exec";
        inherit WorkingDirectory StateDirectory;
        User = cfg.user;
        ExecStart = singleton (getExe cfg.package + " " + cli.toGNUCommandLineShell { } {
          ${if cfg.mqtt.url != null then "mqtt-url" else null} = cfg.mqtt.url;
          client-id = cfg.mqtt.clientId;
          ${if hasHostname then "hostname" else null} = config.networking.hostName;
          unit = cfg.units;
          ${if cfg.mqtt.username != null then "mqtt-username" else null} = cfg.mqtt.username;
        });
        Environment = [
          "RUST_LOG=warn"
        ];
      };
    };
    users.users.${cfg.user} = mkIf cfg.createUser {
      isSystemUser = mkDefault true;
      home = mkDefault WorkingDirectory;
      createHome = mkDefault true;
      group = mkDefault "nogroup";
    };
    security.polkit = optionalAttrs (options ? security.polkit.users) {
      users.${cfg.user} = {
        systemd = {
          inherit (cfg) units;
        };
      };
    };
  }) ];
}

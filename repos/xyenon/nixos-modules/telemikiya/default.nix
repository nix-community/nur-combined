{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.telemikiya;
  exe = lib.getExe cfg.package;
  tomlFormat = pkgs.formats.toml { };
  configFile = tomlFormat.generate "telemikiya-config.toml" cfg.settings;
in
{
  options.services.telemikiya = {
    enable = mkEnableOption "TeleMikiya";

    package = mkPackageOption pkgs "nur.repos.xyenon.telemikiya" { };

    enableBot = mkEnableOption "bot";
    enableEmbedding = mkEnableOption "embedding";
    enableObserver = mkEnableOption "observer";

    stateDir = mkOption {
      default = "/var/lib/telemikiya";
      type = types.str;
      description = "TeleMikiya data directory.";
    };

    user = mkOption {
      type = types.str;
      default = "telemikiya";
      description = "User account under which TeleMikiya runs.";
    };

    group = mkOption {
      type = types.str;
      default = "telemikiya";
      description = "Group under which TeleMikiya runs.";
    };

    settings = mkOption {
      inherit (tomlFormat) type;
      default = { };
      description = ''
        Free-form settings written directly to the `config.toml` config file.
      '';
    };

    environmentFile = mkOption {
      type = with types; nullOr path;
      default = null;
      example = "/run/secrets/telemikiya.env";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.telemikiya = {
      description = "TeleMikiya";
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "postgresql.service"
      ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        # run migrations/init the database
        ${exe} -C '${configFile}' db migrate
      '';
      serviceConfig =
        let
          enableBot = lib.boolToString cfg.enableBot;
          enableEmbedding = lib.boolToString cfg.enableEmbedding;
          enableObserver = lib.boolToString cfg.enableObserver;
        in
        {
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = cfg.stateDir;
          ExecStart = "${exe} -C '${configFile}' run --bot=${enableBot} --embedding=${enableEmbedding} --observer=${enableObserver}";
          Restart = "on-failure";
          RestartSec = "5s";
          EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;
          StateDirectory = [ "telemikiya" ];
          StateDirectoryMode = "700";
          ReadWritePaths = [ cfg.stateDir ];
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
        };
    };

    users = {
      users.${cfg.user} = {
        description = "TeleMikiya Service";
        home = cfg.stateDir;
        inherit (cfg) group;
        isSystemUser = true;
      };
      groups."${cfg.group}" = { };
    };
  };

  meta.maintainers = with lib.maintainers; [ xyenon ];
}

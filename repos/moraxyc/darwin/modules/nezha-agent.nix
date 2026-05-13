{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.nezha-agent;

  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "config.json" cfg.settings;
in
{
  options.services.nezha-agent = {
    enable = lib.mkEnableOption "Agent of Nezha Monitoring";

    package = lib.mkPackageOption pkgs "nezha-agent" { };

    debug = lib.mkEnableOption "verbose log";

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
        };
      };
    };
    clientSecretFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
    };
    genUuid = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf cfg.enable {
    launchd.daemons.nezha-agent = {
      path = [ config.environment.systemPath ];
      script = ''
        CONFIG_DIR="/Library/Application Support/nezha-agent"
        CONFIG_FILE="$CONFIG_DIR/config.json"
        mkdir -p "$CONFIG_DIR"
        cp "${configFile}" "$CONFIG_FILE"
      ''
      + lib.optionalString (cfg.clientSecretFile != null) ''
        ${lib.getExe pkgs.jq} --arg client_secret "$(<"${cfg.clientSecretFile}")" \
          '. + { client_secret: $client_secret }' < "$CONFIG_FILE" > "$CONFIG_FILE".tmp
        mv "$CONFIG_FILE".tmp "$CONFIG_FILE"
      ''
      + lib.optionalString cfg.genUuid ''
        ${lib.getExe pkgs.jq} --arg uuid "$(${lib.getExe' pkgs.util-linux "uuidgen"} --md5 -n @dns -N "${config.networking.hostName}")" \
          '. + { uuid: $uuid }' < "$CONFIG_FILE" > "$CONFIG_FILE".tmp
        mv "$CONFIG_FILE".tmp "$CONFIG_FILE"
      ''
      + ''
        exec ${lib.getExe cfg.package} --config "$CONFIG_FILE"
      '';
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
      }
      // lib.optionalString cfg.debug {
        StandardOutPath = "/Library/Logs/nezha-agent/stdout";
        StandardErrorPath = "/Library/Logs/nezha-agent/stderr";
      };
    };
  };
}

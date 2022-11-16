{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.stalwart-jmap;
  configFormat = pkgs.formats.yaml { };
  configFile =
    if cfg.configFile != null
    then cfg.configFile
    else configFormat.generate "stalwart-jmap" cfg.config;
in
{
  options.services.stalwart-jmap = {
    enable = mkEnableOption "V2Ray v5 service";
    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "The absolute path to the configuration file.";
    };
    config = mkOption {
      type = configFormat.type;
      default = { };
      description = "The configuration attribute set.";
    };
    dbPath = mkOption {
      type = types.path;
      default = "/var/lib/stalwart-jmap";
      description = "RocksDB database path";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = (cfg.configFile != null) -> (cfg.config == { });
      message = "Either but not both `configFile` and `config` should be specified for mosdns.";
    }];

    systemd.services.stalwart-jmap = {
      description = "Stalwart JMAP server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ configFile ];
      serviceConfig = {
        ExecStart = "${pkgs.stalwart-jmap}/bin/stalwart-jmap --config=${configFile}";
      };
    };
  };
}

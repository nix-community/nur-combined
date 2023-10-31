{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.shadow-tls;
  configFormat = pkgs.formats.json { };
  configFile =
    if cfg.configFile != null
    then cfg.configFile
    else
      pkgs.writeTextFile {
        name = "v2ray.json";
        text = builtins.toJSON cfg.config;
      };
in
{
  options.services.shadow-tls = {
    enable = mkEnableOption "shadow-tls service";
    package = mkPackageOption pkgs "shadow-tls" { default = [ "shadow-tls" ]; };
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
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = (cfg.configFile != null) -> (cfg.config == { });
      message = "Either but not both `configFile` and `config` should be specified for shadow-tls.";
    }];

    systemd.services.shadow-tls = {
      description = "shadow-tls Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ configFile ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/shadow-tls config --config ${configFile}";
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}

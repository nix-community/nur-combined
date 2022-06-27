{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.mosdns;
  configFormat = pkgs.formats.yaml { };
  configFile =
    if cfg.configFile != null
    then cfg.configFile
    else configFormat.generate "mosdns.yaml" cfg.config;
in
{
  options.services.mosdns = {
    enable = mkEnableOption "mosdns service";
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
      message = "Either but not both `configFile` and `config` should be specified for mosdns.";
    }];

    systemd.services.mosdns = {
      description = "mosdns Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.mosdns}/bin/mosdns start -c ${configFile}";
      };
    };
  };
}

# Originally from https://github.com/EHfive/flakes/blob/main/modules/mosdns/default.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.mosdns;
  configFormat = pkgs.formats.yaml { };
  configFile =
    if cfg.configFile != null then cfg.configFile else configFormat.generate "mosdns.yaml" cfg.config;
in
{
  options.services.mosdns = {
    enable = mkEnableOption "mosdns service";
    package = mkPackageOption pkgs "mosdns" { default = [ "mosdns" ]; };
    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "The absolute path to the configuration file.";
    };
    config = mkOption {
      inherit (configFormat) type;
      default = { };
      description = "The configuration attribute set.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.configFile != null) -> (cfg.config == { });
        message = "Either but not both `configFile` and `config` should be specified for mosdns.";
      }
    ];

    systemd.services.mosdns = {
      description = "mosdns Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ configFile ];
      serviceConfig = {
        StateDirectory = "mosdns";
        ExecStart = "${cfg.package}/bin/mosdns start -c ${configFile} -d $STATE_DIRECTORY";
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}

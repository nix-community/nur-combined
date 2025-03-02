{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zju-connect;
in
{
  options.programs.zju-connect = {
    enable = lib.mkEnableOption "ZJU Connect";
    package = lib.mkOption {
      type = lib.types.package;
      default = lib.mkPackageOption pkgs "nur.repos.hhr2020.zju-connect" { };
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      example = lib.literalExpression "$XDG_CONFIG_HOME/zju-connect/config.toml";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services.zju-connect = {
      Unit = {
        Description = "ZJU Connect";
        After = [ "network.target" ];
        Wants = [ "network.target" ];
      };

      Service = {
        Restart = "on-failure";
        RestartSec = "5s";
        ExecStart = "${lib.getExe cfg.package} -config ${cfg.configFile}";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}

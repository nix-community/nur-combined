{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.violet;
  inherit (lib)
    mkOption
    types
    mkPackageOption
    mkIf
    ;
in
{
  options.services.violet = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    package = mkPackageOption pkgs "violet" { };
  };
  config = mkIf cfg.enable {
    systemd.services.violet = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "violet Daemon";

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "violet";
        ExecStart = "${lib.getExe cfg.package} -c $\{STATE_DIRECTORY}/config.yaml";
        Restart = "on-failure";
      };
    };
  };
}

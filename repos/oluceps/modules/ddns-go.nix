{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.ddns-go;
in
{
  options.services.ddns-go = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    package = mkPackageOption pkgs "ddns-go" { };
  };
  config = mkIf cfg.enable {
    systemd.services.ddns-go = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "ddns-go Daemon";

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "ddns-go";
        ExecStart = "${lib.getExe cfg.package} -c $\{STATE_DIRECTORY}/config.yaml";
        Restart = "on-failure";
      };
    };
  };
}

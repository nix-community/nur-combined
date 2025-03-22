{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.alist;
  inherit (lib)
    mkPackageOption
    mkIf
    mkEnableOption
    ;
in
{
  options.services.alist = {
    enable = mkEnableOption "alist";
    package = mkPackageOption pkgs "alist" { };
  };
  config = mkIf cfg.enable {
    systemd.services.alist = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "alist Daemon";

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "alist";
        ExecStart = "${lib.getExe cfg.package} server --data $\{STATE_DIRECTORY}";
        Restart = "on-failure";
      };
    };
  };
}

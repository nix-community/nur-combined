{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.services.scx;
in
{
  options.services.scx = {
    enable = mkEnableOption "scx service";
    package = mkPackageOptionMD pkgs "scx" { };
    scheduler = mkOption {
      type = types.str;
      default = "scx_rusty";
    };
  };
  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.scx ];

    systemd.services.scx = {
      wantedBy = [ "multi-user.target" ];
      description = "scheduler daemon";
      serviceConfig = {
        Type = "simple";
        User = "root";
        ExecStart = "${lib.getExe' cfg.package cfg.scheduler}";
        Restart = "on-failure";
      };
    };
  };
}

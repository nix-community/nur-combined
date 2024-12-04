{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    mkPackageOption
    mkEnableOption
    mkIf
    ;

  cfg = config.services.scx;
in
{
  disabledModules = [ "services/scheduling/scx.nix" ];
  options.services.scx = {
    enable = mkEnableOption "scx service";
    package = mkPackageOption pkgs "scx" { };
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

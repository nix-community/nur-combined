{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

let
  cfg = config.services.system76-scheduler-niri;
  defaultPackage = pkgs.callPackage ../../pkgs/system76-scheduler-niri { inherit mylib; };
in
{
  options.services.system76-scheduler-niri = {
    enable = lib.mkEnableOption "Enable system76-scheduler Niri integration";
    package = lib.mkPackageOption defaultPackage "system76-scheduler-niri" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.system76-scheduler-niri = {
      Unit = {
        Description = "Niri integration for system76-scheduler";
        After = [ "niri.service" ];
      };
      Service = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "niri.service" ];
      };
    };
  };
}

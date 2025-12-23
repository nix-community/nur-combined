{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.system76-scheduler-niri;
  mylib = import ../../lib { inherit pkgs; };
  myCallPackage = pkgs.newScope (pkgs // mylib);
  defaultPackage = myCallPackage ../../pkgs/system76-scheduler-niri { };
in
{
  options.services.system76-scheduler-niri = {
    enable = lib.mkEnableOption "Enable system76-scheduler Niri integration";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "The system76-scheduler-niri package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.system76-scheduler.enable = true;

    systemd.user.services.system76-scheduler-niri = {
      description = "Niri integration for system76-scheduler";

      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [
        "graphical-session.target"
        "niri.service"
      ];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = "3s";
      };
    };
  };
}

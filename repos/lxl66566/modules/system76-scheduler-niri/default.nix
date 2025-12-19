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
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "The system76-scheduler-niri package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.system76-scheduler-niri = {
      description = "Niri integration for system76-scheduler";

      after = [ "niri.service" ];

      wantedBy = [ "niri.service" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
      };
    };
  };
}

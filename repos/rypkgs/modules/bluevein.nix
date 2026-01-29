{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.bluevein;
in
{
  options.services.bluevein = {
    enable = lib.mkEnableOption "BlueVein Bluetooth key sync service for dual-boot systems";

    package = lib.mkPackageOption pkgs "bluevein" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.bluevein = {
      description = "BlueVein Bluetooth Key Sync Service";
      after = [ "bluetooth.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
    };
  };
}

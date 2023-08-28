{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.eg25-control;
in
{
  options.sane.services.eg25-control = with lib; {
    enable = mkEnableOption "Quectel EG25 modem configuration scripts. alternative to eg25-manager";
    package = mkOption {
      type = types.package;
      default = pkgs.eg25-control;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.eg25-control = {
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/eg25-control --power-on --enable-gps --dump-debug-info --verbose";
        Restart = "on-failure";
        RestartSec = "60s";
      };
      after = [ "ModemManager.service" ];
      wants = [ "ModemManager.service" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}

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
    systemd.services.eg25-control-powered = {
      description = "power to the Qualcomm eg25 modem used by PinePhone";
      serviceConfig = {
        Type = "simple";
        RemainAfterExit = true;
        ExecStart = "${cfg.package}/bin/eg25-control --power-on --verbose";
        ExecStop = "${cfg.package}/bin/eg25-control --power-off --verbose";
        Restart = "on-failure";
        RestartSec = "60s";
      };
      after = [ "ModemManager.service" ];
      wants = [ "ModemManager.service" ];
      # wantedBy = [ "multi-user.target" ];
    };
    systemd.services.eg25-control-gps = {
      # TODO: separate almanac upload from GPS enablement
      # - don't want to re-upload the almanac everytime the GPS is toggled
      # - want to upload almanac even when GPS *isn't* enabled, if we have internet connection.
      description = "background GPS tracking";
      serviceConfig = {
        Type = "simple";
        RemainAfterExit = true;
        ExecStart = "${cfg.package}/bin/eg25-control --enable-gps --dump-debug-info --verbose";
        ExecStop = "${cfg.package}/bin/eg25-control --disable-gps --dump-debug-info --verbose";
        Restart = "on-failure";
        RestartSec = "60s";
      };
      after = [ "eg25-control-powered.service" ];
      requires = [ "eg25-control-powered.service" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}

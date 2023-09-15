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
    users.groups.eg25-control = {};
    users.users.eg25-control = {
      group = "eg25-control";
      isSystemUser = true;
      home = "/var/lib/eg25-control";
      extraGroups = [
        "networkmanager"  # required to authenticate with mmcli
      ];
    };
    sane.persist.sys.plaintext = [
      { user = "eg25-control"; group = "eg25-control"; path = "/var/lib/eg25-control"; }
    ];

    systemd.services.eg25-control-powered = {
      description = "power to the Qualcomm eg25 modem used by PinePhone";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${cfg.package}/bin/eg25-control --power-on --verbose";
        ExecStop = "${cfg.package}/bin/eg25-control --power-off --verbose";
        Restart = "on-failure";
        RestartSec = "60s";

        # XXX /sys/class/modem-power/modem-power/device/powered is writable only by root
        # User = "eg25-control";
        # WorkingDirectory = "/var/lib/eg25-control";
        # StateDirectory = "eg25-control";
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

        User = "eg25-control";
        WorkingDirectory = "/var/lib/eg25-control";
        StateDirectory = "eg25-control";
      };
      after = [ "eg25-control-powered.service" ];
      requires = [ "eg25-control-powered.service" ];
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.eg25-control-freshen-agps = {
      description = "keep assisted-GPS data fresh";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/eg25-control --ensure-agps-cache --verbose";

        User = "eg25-control";
        WorkingDirectory = "/var/lib/eg25-control";
        StateDirectory = "eg25-control";
      };
      after = [ "network-online.target" "nss-lookup.target" ];
      requires = [ "network-online.target" ];
    };

    systemd.timers.eg25-control-freshen-agps = {
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnCalender = "hourly";  # this is a bit more than necessary, but idk systemd calendar syntax
        OnStartupSec = "3min";
      };
    };
  };
}

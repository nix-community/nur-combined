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
        "dialout"  # required to read /dev/ttyUSB1
        "networkmanager"  # required to authenticate with mmcli
      ];
    };
    sane.persist.sys.byStore.plaintext = [
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
        TimeoutSec = "60s";

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
      # wantedBy = [ "multi-user.target" ];
    };

    systemd.services.eg25-control-freshen-agps = {
      description = "keep assisted-GPS data fresh";
      serviceConfig = {
        # XXX: this can have a race condition with eg25-control-gps
        # - eg25-control-gps initiates DL of new/<agps>
        # - eg25-control-gps tests new/<agps>: it works
        # - eg25-control-freshen-agps initiates DL of new/<agps>
        # - eg25-control-gps: moves new/<agps> into cache/
        #   - but it moved the result (possibly incomplete) of eg25-control-freshen-agps, incorrectly
        # in practice, i don't expect much issue from this.
        ExecStart = "${cfg.package}/bin/eg25-control --ensure-agps-cache --verbose";
        Restart = "no";

        User = "eg25-control";
        WorkingDirectory = "/var/lib/eg25-control";
        StateDirectory = "eg25-control";
      };
      startAt = "hourly";  # this is a bit more than necessary, but idk systemd calendar syntax
      after = [ "network-online.target" "nss-lookup.target" ];
      requires = [ "network-online.target" ];
      # wantedBy = [ "network-online.target" ]; # auto-start immediately after boot
    };
  };
}

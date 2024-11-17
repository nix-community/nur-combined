{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.eg25-control;
in
{
  sane.programs.eg25-control = {
    suggestedPrograms = [ "mmcli" ];

    sandbox.extraPaths = [
      "/dev/gpiochip0"  # Pinephone Pro
      "/dev/gpiochip1"  # Pinephone
      "/dev/gpiochip3"  # Pinephone Pro
      # "/sys/class/modem-power"
      "/sys/bus/gpio"
      "/sys/dev/char"
      "/sys/devices"
      # "/var/lib/eg25-control"
    ];
    sandbox.net = "all";  #< for downloading the almanac
    sandbox.whitelistDbus = [
      "system"  #< used by `mmcli`
    ];

    services.eg25-control-powered = {
      description = "eg25-control-powered: power to the Qualcomm eg25 modem used by PinePhone";
      startCommand = "eg25-control --power-on --verbose";
      cleanupCommand = "eg25-control --power-off --verbose";
      # depends = [ "ModemManager" ]
    };

    services.eg25-control-gps = {
      # TODO: separate almanac upload from GPS enablement
      # - don't want to re-upload the almanac everytime the GPS is toggled
      # - want to upload almanac even when GPS *isn't* enabled, if we have internet connection.
      description = "eg25-control-gps: background GPS tracking";
      startCommand = "eg25-control --enable-gps --dump-debug-info --verbose";
      cleanupCommand = "eg25-control --disable-gps --dump-debug-info --verbose";
      depends = [ "eg25-control-powered" ];
      partOf = [ "gps" ];
    };

    persist.byStore.plaintext = [ ".cache/eg25-control" ];  #< for cached agps data
  };

  # TODO: port to s6
  systemd.services.eg25-control-freshen-agps = lib.mkIf cfg.enabled {
    description = "keep assisted-GPS data fresh";
    serviceConfig = {
      # XXX: this can have a race condition with eg25-control-gps
      # - eg25-control-gps initiates DL of new/<agps>
      # - eg25-control-gps tests new/<agps>: it works
      # - eg25-control-freshen-agps initiates DL of new/<agps>
      # - eg25-control-gps: moves new/<agps> into cache/
      #   - but it moved the result (possibly incomplete) of eg25-control-freshen-agps, incorrectly
      # in practice, i don't expect much issue from this.
      ExecStart = "${lib.getExe cfg.package} --ensure-agps-cache --verbose";
      Restart = "no";

      User = "colin";
    };
    startAt = "hourly";  # this is a bit more than necessary, but idk systemd calendar syntax
    after = [ "network-online.target" "nss-lookup.target" ];
    requires = [ "network-online.target" ];
    # wantedBy = [ "network-online.target" ]; # auto-start immediately after boot
  };

  services.udev.extraRules = lib.optionalString cfg.enabled ''
    # make modem controllable by user
    # DRIVER=="modem-power", RUN+="chmod g+w /sys%p/powered", RUN+="chown :networkmanager /sys%p/powered"
    SUBSYSTEM=="gpio", MODE="660" GROUP="input"
  '';
}

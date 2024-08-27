{
  config,
  pkgs,
  lib,
  ...
}:
{
  services = {
    #desktopManager.cosmic.enable = true;
    #displayManager.cosmic-greeter.enable = true;
    dbus.implementation = "broker"; # lock dbus impl to dbus-broker
    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="adbusers"
    '';
    fstrim.enable = true;
    openssh = {
      enable = true;
      settings.PermitRootLogin = lib.mkDefault "no";
    };
    printing.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        # START_CHARGE_THRESH_BAT0 = 85;
        # STOP_CHARGE_THRESH_BAT0 = 90;
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      user = "zzzsy";
      group = "users";
      downloadDirPermissions = "755";
      home = "/home/zzzsy";
      settings = {
        download-dir = "${config.services.transmission.home}/Downloads/Transmission";
        incomplete-dir-enabled = false;
      };
    };
    earlyoom = {
      enable = true;
    };
    # blueman.enable = true;
  };
}

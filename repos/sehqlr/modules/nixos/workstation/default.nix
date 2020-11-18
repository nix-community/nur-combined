{ config, pkgs, ... }: {
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking = {
    hostName = "workstation";
    nameservers = [ "8.8.8.8" ];
    wireless.enable = true;
  };

  time.timeZone = "America/Chicago";

  services.vnstat.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.wacom.enable = true;
}

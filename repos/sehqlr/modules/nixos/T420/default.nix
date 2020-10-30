{ config, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "T420"; # Define your hostname.

  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  time.timeZone = "America/Chicago";

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  services.xserver.libinput.enable = true;

  programs.light.enable = true;
}

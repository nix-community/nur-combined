{ config, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;

  networking = {
      hostName = "T420";
      interfaces = {
          enp0s25.useDHCP = true;
          wlp3s0.useDHCP = true;
      };
      networkmanager.wifi.powersave = false;
  };

  time.timeZone = "America/Chicago";

  services.printing.enable = true;

  sound.enable = true;
  sound.mediaKeys.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.libinput.enable = true;

  programs.light.enable = true;
}

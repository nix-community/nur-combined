{ config, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;

  networking = {
      hostName = "T420";
      interfaces = {
          enp0s25.useDHCP = true;
          wlp3s0.useDHCP = true;
      }
      networkmanager = {
          enable = true;
          wifi.powersave = false;
      }
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  time.timeZone = "America/Chicago";

  services.printing.enable = true;

  sound.enable = true;
  sound.mediaKeys.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.libinput.enable = true;

  programs.light.enable = true;

  users.users.sam.extraGroups = [ "networkmanager" ];
}

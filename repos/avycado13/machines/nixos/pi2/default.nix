{ lib, pkgs, ... }:
{
  networking.hostName = "pi2";
  networking.useDHCP = true;

  # Pi 2 v1.3 has a 64-bit CPU; select the Pi 3 U-Boot image for it.
  sdImage.populateFirmwareCommands = lib.mkAfter ''
    chmod u+w firmware/config.txt
    printf '\n[pi2]\nkernel=u-boot-rpi3.bin\n' >> firmware/config.txt
    chmod u-w firmware/config.txt
  '';

  zramSwap.enable = true;
  zramSwap.memoryPercent = 90;

  nix-mineral.enable = lib.mkForce false;
  services.smartd.enable = lib.mkForce false;

  services.xserver.windowManager.jwm.enable = true;
  services.xserver.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "avy";
        command = lib.getExe' pkgs.tuigreet "tuigreet"; # you may pass `--config` here
      };
    };
  };
  system.stateVersion = "26.05";
}

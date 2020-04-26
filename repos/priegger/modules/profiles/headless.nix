{ config, lib, pkgs, ... }:
with lib;
let
  common = import ./common.nix { inherit config pkgs lib; };
in
recursiveUpdate common {
  environment.systemPackages = common.environment.systemPackages ++ (
    with pkgs; [
      # dev tools
      git

      # misc tools
      (gnupg.override { guiSupport = false; })
    ]
  );

  programs.mosh.enable = mkDefault true;


  # --- defaults from the kampka headless profile ---

  environment.noXlibs = mkDefault true;

  services.udisks2.enable = mkDefault false;
  security.polkit.enable = mkDefault false;

  nix.gc = mkDefault {
    automatic = true;
    options = "--delete-older-than 7d";
  };


  # --- defaults from the nixos headless profile ---

  boot.vesa = false;

  # Don't start a tty on the serial consoles.
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = null;
}

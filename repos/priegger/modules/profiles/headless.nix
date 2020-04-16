{ config, lib, pkgs, ... }:
with lib;
let
  common = import ./common.nix { inherit config pkgs lib; };
in
recursiveUpdate common {

  nix.gc = mkDefault {
    automatic = true;
    options = "--delete-older-than 7d";
  };


  # --- defaults from the nixos headless profile ---

  boot.vesa = mkDefault false;

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = null;
}

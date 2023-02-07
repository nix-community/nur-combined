{ config, pkgs, lib, flake, ... }:
let mode = "desktop";
in {
  imports = [
    ../../modules/agenix
    ../../modules/clamav
    ../../modules/fonts
    ../../modules/gnupg
    ../../modules/hardware/raspberry-pi-4
    ../../modules/lorri
    ../../modules/networking
    ../../modules/nix
    ../../modules/openssh
    ../../modules/raspberry-pi/${mode}.nix
    ../../modules/sudo
    ../../modules/tailscale
    ../../modules/time
    ../../modules/zsh
  ];
}

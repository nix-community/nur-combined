{ config, pkgs, lib, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    ../modules/proliant.nix
    ../modules/ams.nix
  ];

  hardware.proliant.enable = true;

  # Don't start the X server by default.
  # It's annoying if I only want to use it to install
  services.xserver.autorun = lib.mkForce false;
}

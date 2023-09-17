{ config, pkgs, lib, inputs, materusFlake, ... }:
{
  imports =
    [

      ./hardware
      ./vm

      ./scripts.nix
      ./tmp.nix
      ./network.nix

      ./kde.nix
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.copySystemConfiguration = false;
  system.stateVersion = "23.05";


  materus.profile.nix.enable = true;
  materus.profile.nixpkgs.enable = true;
  materus.profile.fonts.enable = true;
  materus.profile.steam.enable = true;

}

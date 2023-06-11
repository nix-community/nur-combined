{ config, lib, pkgs, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./configuration.nix
    ];
  materus.profile.nix.enable = true;
  materus.profile.steam.enable = true;


}

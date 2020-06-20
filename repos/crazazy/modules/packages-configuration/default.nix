{ config, pkgs, ... }:
{
  imports = [
    ../steam-configuration
  ];
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = import ./packages.nix;
  };
}

let
  inherit (import ../../nix) sources overlay;
in
{ config, pkgs, ... }:
{
  imports = [
    ../steam-configuration
  ];
  nix.nixPath = [
    "nixpkgs=${sources.nixpkgs-channels}"
    "nixos-config=/etc/nixos/configuration.nix"
  ];
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = import ./packages.nix;
    overlays = [
      overlay
    ];
  };
}

let
  inherit (import ../../nix) sources overlay;
in
{ config, pkgs, ... }:
{
  imports = [
    ../steam-configuration
  ];
  nix = {
    nixPath = [
      "nixpkgs=${sources.nixpkgs-channels}"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://crazazy.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" # public key given by nixos
      "crazazy.cachix.org-1:3KaIHK26pkvd5palJH5A4Re1Hn2+GDV+aXYnftMYAm4=" # my own cache
    ];
  };
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = import ./packages.nix;
    overlays = [
      overlay
    ];
  };
}

let
  inherit (import ../../nix) sources overlay;
in
{ config, pkgs, system ? "", ... }:
{
  imports = [
    ../steam-configuration
  ];
  nix = {
    nixPath = [
      "nixpkgs=${../../.}"
      "nixos-config=/etc/nixos/configuration.nix" # nixos can't change if we change this to a relative path
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
  nixpkgs.pkgs = import sources.nixpkgs {
    # new nix doesnt have builtins.currentSystem, but old nix doesn have a system argument
    system = builtins.currentSystem or system;
    config = {
      allowUnfree = true;
      packageOverrides = import ./packages.nix;
      overlays = [
        overlay
      ];
    };
  };
}

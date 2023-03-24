let
  inherit (import ../../nix) sources overlay;
in
{ config, pkgs, lib, system ? "", ... }:
{
  imports = [
    # ../steam-configuration
    ../nix-experimental
  ];
  programs.steam.enable = true;
  nix = {
    nixPath = [
      "nixpkgs=${lib.cleanSource ../../.}"
      "nixos-config=/etc/nixos/configuration.nix" # nixos can't change if we change this to a relative path
    ];
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://crazazy.cachix.org"
      "https://emacsng.cachix.org"
      "https://ethancedwards8.cachix.org"
      "https://nix-community.cachix.org"
      "https://nrdxp.cachix.org"
      "https://rycee.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" # public key given by nixos
      "crazazy.cachix.org-1:3KaIHK26pkvd5palJH5A4Re1Hn2+GDV+aXYnftMYAm4=" # my own cache
      "emacsng.cachix.org-1:i7wOr4YpdRpWWtShI8bT6V7lOTnPeI7Ho6HaZegFWMI=" # emacs-ng cache
      "ethancedwards8.cachix.org-1:YMasjqyFnDreRQ9GXmnPIshT3tYyFHE2lUiNhbyIxOc=" # guix cache (for testing)
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" # mostly emacs-overlay
      "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4=" # flake shit
      "rycee.cachix.org-1:TiiXyeSk0iRlzlys4c7HiXLkP3idRf20oQ/roEUAh/A=" # for updating my firefox plugins
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

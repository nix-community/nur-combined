{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit (pkgs) lib; };
  modules = import ./modules; # NixOS modules.
  overlays = import ./overlays; # Nixpkgs overlays.
  hmModules = import ./hm-modules; # Home Manager modules.
  ndModules = import ./nd-modules; # nix-darwin modules.

  firefox-addons = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });

  materia-theme = pkgs.callPackage ./pkgs/materia-theme { };

  mozilla-addons-to-nix = pkgs.haskellPackages.callPackage ./pkgs/mozilla-addons-to-nix { };

  nix-stray-roots = pkgs.callPackage ./pkgs/nix-stray-roots { };
}

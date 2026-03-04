{
  pkgs ? import <nixpkgs> { },
}:
let
  lib = import ./lib { inherit (pkgs) lib; };
  buildMozillaXpiAddon = lib.mozilla.mkBuildMozillaXpiAddon { inherit (pkgs) fetchurl stdenv; };
in
{
  inherit lib;

  modules = import ./modules; # NixOS modules.
  overlays = import ./overlays; # Nixpkgs overlays.
  hmModules = import ./hm-modules; # Home Manager modules.
  ndModules = import ./nd-modules; # nix-darwin modules.

  firefox-addons = pkgs.lib.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/firefox-addons { inherit buildMozillaXpiAddon; }
  );

  materia-theme = pkgs.callPackage ./pkgs/materia-theme { };

  mozilla-addons-to-nix = pkgs.haskellPackages.callPackage ./pkgs/mozilla-addons-to-nix { };

  nix-stray-roots = pkgs.callPackage ./pkgs/nix-stray-roots { };

  thunderbird-addons = pkgs.lib.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/thunderbird-addons { inherit buildMozillaXpiAddon; }
  );
}

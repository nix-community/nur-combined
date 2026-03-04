{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            libMozilla = import ../../lib/mozilla.nix { lib = pkgs.lib; };
            buildMozillaXpiAddon = libMozilla.mkBuildMozillaXpiAddon { inherit (pkgs) fetchurl stdenv; };
          in
          f {
            inherit system pkgs;
            addons = import ./. {
              inherit buildMozillaXpiAddon;
              inherit (pkgs) fetchurl lib stdenv;
            };
          }
        );
    in
    {
      lib = forAllSystems (
        { addons, ... }:
        {
          inherit (addons) buildFirefoxXpiAddon;
        }
      );

      packages = forAllSystems (
        { addons, pkgs, ... }: pkgs.lib.filterAttrs (name: val: name != "buildFirefoxXpiAddon") addons
      );

      overlays.default = final: prev: {
        firefox-addons = final.callPackage ./. {
          buildMozillaXpiAddon =
            let
              libMozilla = import ../../lib/mozilla.nix { inherit (prev) lib; };
            in
            libMozilla.mkBuildMozillaXpiAddon { inherit (final) fetchurl stdenv; };
        };
      };
    };
}

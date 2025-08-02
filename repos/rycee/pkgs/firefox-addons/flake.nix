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
          in
          f {
            inherit system pkgs;
            addons = import ./. { inherit (pkgs) fetchurl lib stdenv; };
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
        { addons, ... }: nixpkgs.lib.filterAttrs (name: val: name != "buildFirefoxXpiAddon") addons
      );

      overlays.default = final: prev: {
        firefox-addons = final.callPackage ./. { };
      };
    };
}

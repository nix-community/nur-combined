{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        addons = import ./. { inherit (pkgs) fetchurl lib stdenv; };
      in {
        lib = { inherit (addons) buildFirefoxXpiAddon; };
        packages =
          nixpkgs.lib.filterAttrs (name: val: name != "buildFirefoxXpiAddon")
          addons;
      });
}

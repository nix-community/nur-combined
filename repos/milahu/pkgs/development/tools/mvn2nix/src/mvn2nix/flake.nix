{
  description = "Easily package your Maven Java application with the Nix package manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
  let
    # put devShell and any other required packages into local overlay
    localOverlay = import ./overlay.nix;

    pkgsForSystem = system: import nixpkgs {
      overlays = [
        localOverlay
      ];
      inherit system;
    };
  in utils.lib.eachSystem utils.lib.defaultSystems (system: rec {
    legacyPackages = pkgsForSystem system;
    packages = utils.lib.flattenTree {
      inherit (legacyPackages) mvn2nix mvn2nix-bootstrap buildMavenRepository buildMavenRepositoryFromLockFile;
    };
    defaultPackage = packages.mvn2nix;
    apps.mvn2nix = utils.lib.mkApp { drv = packages.mvn2nix; };
  }) // {
    overlay = localOverlay;
  };
}

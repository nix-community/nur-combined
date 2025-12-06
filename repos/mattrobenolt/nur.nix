# default.nix - NUR compatibility
# This file duplicates logic from flake.nix to avoid using builtins.getFlake
{ pkgs }:

let
  # Load Go versions and hashes (same as flake.nix)
  goVersions = builtins.fromJSON (builtins.readFile ./pkgs/go/versions.json);
  goHashes = builtins.fromJSON (builtins.readFile ./pkgs/go/hashes.json);

  # Helper to create a Go package for a specific version
  makeGo = majorMinor:
    let
      version = goVersions.${majorMinor};
      hashes = goHashes.${version};
    in
    pkgs.callPackage ./pkgs/go {
      inherit version hashes;
    };

  # Get the latest Go version (highest minor version)
  latestGoVersion = builtins.head (builtins.sort (a: b: a > b) (builtins.attrNames goVersions));

  # Create all go-bin_1_XX packages dynamically
  dynamicGoPackages = builtins.listToAttrs (
    map
      (majorMinor: {
        name = "go-bin_" + (builtins.replaceStrings [ "." ] [ "_" ] majorMinor);
        value = makeGo majorMinor;
      })
      (builtins.attrNames goVersions)
  );
in
{
  # Main packages
  zlint = pkgs.callPackage ./pkgs/zlint { };
  zlint-unstable = pkgs.callPackage ./pkgs/zlint/unstable.nix { };
  go-bin = makeGo latestGoVersion;

  # NUR metadata
  modules = [ ];
  overlays = { };
} // dynamicGoPackages

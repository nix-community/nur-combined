# This file exists only for NUR compatibility, the main entry point is flake.nix
{ pkgs }:
let
  inherit (pkgs) lib;
  vaculib = import ./vaculib { inherit lib; };
  commonArgs = {
    inherit lib;
    inherit vaculib;
    vacuRoot = ./.;
  };
  packagePaths = import ./packages commonArgs;
  pythonPackagePaths = import ./pythonPackages commonArgs;
  vacupkglib = import ./vacupkglib (commonArgs // { inherit pkgs; });
  overlays = [
    (_: _: {
      inherit vacupkglib vaculib;
      vacuRoot = ./.;
    })
    (import ./overlays/newPackages.nix)
    (import ./overlays/newPythonPackages.nix)
  ];
  betterPkgs = pkgs.appendOverlays overlays;
in
lib.attrsets.unionOfDisjoint
  (lib.getAttrs (builtins.attrNames packagePaths) betterPkgs)
  {
    python3Packages = lib.getAttrs (builtins.attrNames pythonPackagePaths) betterPkgs.python3Packages;
  }

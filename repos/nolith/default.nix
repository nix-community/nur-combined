# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  pkgsFolder = ./pkgs;
  entries = builtins.readDir pkgsFolder;
  # generate a dynamic attrset based on the contents of the pkgs folder
  nolithPkgs =
    builtins.listToAttrs
    # make sure we only import packages that are a folder and where an default.nix file exists
    (builtins.filter (x: x != null)
      (map (
          name:
            if entries.${name} == "directory" && builtins.pathExists (pkgsFolder + "/${name}/default.nix")
            then {
              inherit name;
              value = pkgs.callPackage (pkgsFolder + "/${name}") {};
            }
            else null
        )
        (builtins.attrNames entries)));
in
  {
    # The `lib`, `modules`, and `overlays` names are special
    lib = import ./lib {inherit pkgs;}; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays {inherit nolithPkgs;}; # nixpkgs overlays
    python3Packages = let
      callPackage = pkgs.python3.pkgs.callPackage;
    in
      pkgs.recurseIntoAttrs {
        srtmpy = callPackage ./pkgs/python-packages/srtmpy {};
        python-srtm = callPackage ./pkgs/python-packages/python-srtm {};
      };
    gpxtofitconverter = pkgs.python3.pkgs.callPackage ./pkgs/python-packages/gpxtofitconverter {};
  }
  // nolithPkgs

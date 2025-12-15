# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
# mode:
# - null: Default mode
# - "ci": from Garnix CI
# - "nur": from NUR bot
# - "legacy": from legacyPackages
mode:
{
  pkgs ? import <nixpkgs> { },
  inputs ? null,
  ...
}:
let
  inherit (pkgs) lib;
  inherit (import ../helpers/group.nix { inherit pkgs lib mode inputs; })
    doFlatGroupPackages
    doGroupPackages
    ifNotCI
    ifNotNUR
    ;

  flatGroups = {
    deprecated = ifNotCI ./deprecated;
    kernel-modules = ./kernel-modules;
    python3Packages = ./python-packages;
    uncategorized = ./uncategorized;
  };

  groups = {
    # Binary cache information
    _meta = ./_meta;

    # Package groups
    asteriskDigiumCodecs = ./asterisk-digium-codecs;
    lantianCustomized = ./lantian-customized;
    lantianLinuxCachyOS = ifNotNUR (ifNotCI ./lantian-linux-cachyos);
    lantianLinuxCachyOSPackages = ifNotNUR (ifNotCI ./lantian-linux-cachyos/packages.nix);
    nvidia-grid = ifNotCI ./nvidia-grid;
    openj9-ibm-semeru = ifNotCI ./openj9-ibm-semeru;
    openjdk-adoptium = ifNotCI ./openjdk-adoptium;
    th-fonts = ./th-fonts;
  };

  self = lib.foldl (a: b: a // b) (
    (doGroupPackages self groups) // (doGroupPackages self flatGroups)
  ) (builtins.attrValues (doFlatGroupPackages self flatGroups));
in
self

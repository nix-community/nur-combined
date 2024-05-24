# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
  gpd-fan-driver,
  ...
}:
let

  lib = pkgs.lib;

  linux-packages = [
    {
      name = "";
      package = pkgs.linuxPackages;
    }
    {
      name = "_zen";
      package = pkgs.linuxPackages_zen;
    }
    {
      name = "_latest";
      package = pkgs.linuxPackages_latest;
    }
  ];
in
lib.attrsets.mergeAttrsList (
  lib.lists.forEach linux-packages (
    linux-package:
    lib.attrsets.mapAttrs'
      (
        name: package:
        lib.attrsets.nameValuePair (name + linux-package.name) (
          linux-package.package.callPackage package { }
        )
      )
      {
        bmi260 = ../pkgs/linux/bmi260.nix;
        gpd-fan-driver = gpd-fan-driver.modulePackage;
      }
  )
)

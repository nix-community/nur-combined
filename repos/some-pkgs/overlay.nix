# FIXME: This is one huge pile of mess that hasn't been maintained since, about, early 2024.

final: prev:

let
  lib' = prev.lib;
  inherit (import ./lib/extend-lib.nix { oldLib = prev.lib; }) lib;
  inherit (lib) readByName autocallByName;
  toplevelFiles = readByName ./pkgs/by-name;
  pythonFiles = readByName ./python-packages/by-name;
  inputs = import ./lon.nix;
in
{
  inherit lib;
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (py-final: py-prev: {
      some-pkgs-py = py-final.callPackage ./pythonScope.nix { withSomePkgs = final.some-pkgs; };
    })
  ];
}
// lib.keepMissing prev {
  inherit (final.some-pkgs) some-datasets some-util some-pkgs-py;
  some-pkgs = final.recurseIntoAttrs (final.callPackage ./scope.nix { });
  nixglhost = final.callPackage (inputs.nix-gl-host + "/default.nix");
}
// lib'.optionalAttrs (lib'.versionOlder lib'.version "23.11") {
  # 2023-08-28: NUR still uses the 23.05 channel which doesen't handle pythonPackagesExtensions
  python3 =
    let
      self = prev.python3.override {
        packageOverrides = lib'.composeManyExtensions final.pythonPackagesExtensions;
        inherit self;
      };
    in
    self;
  python3Packages = final.python3.pkgs;
}

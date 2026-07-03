{ pkgs ? import <nixpkgs> { } }:

let
  packageDirs =
    pkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);

  packagesFor =
    emacsPackages:
    let
      callPackage = pkgs.lib.callPackageWith (
        pkgs // {
          inherit emacsPackages;
        }
      );
    in
    builtins.mapAttrs
      (name: _: callPackage (./. + "/${name}") { })
      packageDirs;
in
packagesFor pkgs.emacsPackages
// {
  for = packagesFor;
}

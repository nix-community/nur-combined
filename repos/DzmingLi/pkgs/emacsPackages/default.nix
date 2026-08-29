{
  pkgs ? import <nixpkgs> { },
}:

let
  packageDirs = pkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);

  packagesFor =
    emacsPackages:
    let
      packages = builtins.mapAttrs (name: _: callPackage (./. + "/${name}") { }) packageDirs;
      callPackage = pkgs.lib.callPackageWith (
        pkgs
        // {
          inherit emacsPackages;
        }
        // packages
      );
    in
    packages;
  defaultPackages = packagesFor pkgs.emacsPackages;
  emacs31Packages = packagesFor (pkgs.emacsPackagesFor pkgs.emacs31);
in
defaultPackages
// {
  # These packages intentionally target Emacs 31 and newer.  Keep the generic
  # `for` package set below so overlay consumers still receive builds matching
  # their selected Emacs.
  inherit (emacs31Packages) douban elfeed-adapters zhihu;
  for = packagesFor;
}

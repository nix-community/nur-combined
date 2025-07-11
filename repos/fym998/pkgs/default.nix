{
  pkgs,
  lib ? pkgs.lib,
  ...
}:
let
  legacyPackages =
    lib.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ./by-name;
    }
    // {
      fprintd-fpcmoh = pkgs.callPackage ./by-name/fprintd-fpcmoh/package.nix {
        inherit (legacyPackages) libfprint-fpcmoh;
      };
    };
in
{
  inherit legacyPackages;

  packages =
    let
      # from https://github.com/drupol/pkgs-by-name-for-flake-parts/blob/main/flake-module.nix
      flattenPkgs =
        separator: path: value:
        if lib.isDerivation value then
          {
            ${lib.concatStringsSep separator path} = value;
          }
        else if lib.isAttrs value then
          lib.concatMapAttrs (name: flattenPkgs separator (path ++ [ name ])) value
        else
          # Ignore the functions which makeScope returns
          { };
    in
    flattenPkgs "." [ ] legacyPackages;
}

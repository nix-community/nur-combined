# NUR entry point (https://github.com/nix-community/NUR): returns every
# package under pkgs/, so adding a package is adding a directory. flake.nix
# builds its outputs from this same file.
{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;

  names = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./pkgs)
  );

  # Packages resolve each other by argument name. A package that adapts the
  # nixpkgs package of the same name (albert, scroll-reverser) is handed the
  # nixpkgs one, not itself.
  callPackage = lib.callPackageWith (pkgs // packages);
  packages = lib.genAttrs names (
    name:
    let
      file = ./pkgs/${name}/package.nix;
    in
    callPackage file (
      lib.optionalAttrs (builtins.functionArgs (import file) ? ${name}) { ${name} = pkgs.${name}; }
    )
  );
in
packages

{ pkgs ? import <nixpkgs> { } }:
with pkgs.lib;
let
  lib = import ./lib { inherit (pkgs) lib; };

  callPackageSet = path: lib.makePackageSet (pkgs.callPackage path { });

  collectPackages = path:
    let
      dir = ./. + (concatStringsSep "/" path);
      dirname = last path;
      set = builtins.readDir dir;
    in
    (if builtins.hasAttr "package.nix" set then
      { ${dirname} = pkgs.callPackage (dir + "/package.nix") { }; }
    else if builtins.hasAttr "packages.nix" set then
      { ${dirname} = callPackageSet (dir + "/packages.nix"); }
    else
      { }) //
    (foldl'
      (acc: name: acc //
      (optionalAttrs (set.${name} == "directory") (collectPackages (path ++ [ name ]))))
      { }
      (attrNames set));
in
collectPackages [ "/modules" ]

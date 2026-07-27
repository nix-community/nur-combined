{ pkgs }:
let
  all = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = callPackage';
    directory = ./pkgs;
  };

  callPackage' =
    pkg: args:
    pkgs.lib.recurseIntoAttrs (
      pkgs.lib.callPackageWith (
        (pkgs.lib.recursiveUpdate pkgs all)
        // {
          inherit callPackage';
          sources = pkgs.callPackage (
            (
              if pkgs.lib.pathIsDirectory pkg then
                pkg
              else
                (pkgs.lib.join "/" (pkgs.lib.dropEnd 1 (pkgs.lib.splitString "/" pkg)))
            )
            + "/_sources/generated.nix"
          ) { };
        }
      ) pkg args
    );
in
all

{ pkgs }:
let
  inherit (pkgs) lib;
  lib' = lib // {
    maintainers = lib.maintainers // {
      eownerdead = {
        name = "EOWNERDEAD";
        email = "eownerdead@disroot.org";
        github = "eownerdead";
        githubId = 141208772;
        keys = [{
          fingerprint = "4715 17D6 2495 A273 4DDB  5661 009E 5630 5CA5 4D63";
        }];
      };
    };
  };
  callPackage = pkgs.lib.callPackageWith (pkgs // { lib = lib'; });
in lib.mapAttrs (name: ty: callPackage ./${name}/package.nix { })
(lib.filterAttrs (name: ty: ty == "directory") (builtins.readDir ./.))

{ lib, version ? lib.trivial.release }:

let

  inherit (builtins) abort fetchTarball fromJSON getAttr hasAttr readFile;

  branchMap = {
    "19.03" = ./release-19.03.json;
    "19.09" = ./release-19.09.json;
    "20.03" = ./release-20.03.json;
    "20.09" = ./release-20.09.json;
    "21.03" = ./release-21.05.json;
    "21.05" = ./release-21.05.json;
    "21.11" = ./release-21.11.json;
    "22.05" = ./release-22.05.json;
    "22.11" = ./master.json;
  };

  getOrAbort = err: key: attrs:
    if hasAttr key attrs then getAttr key attrs else abort err;

  branch = let err = "No Home Manager branch available for Nixpkgs ${version}";
  in getOrAbort err version branchMap;

in fetchTarball
({ name = "home-manager-${version}"; } // fromJSON (readFile branch))

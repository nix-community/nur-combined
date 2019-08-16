{ fetchFromGitLab, lib
, version ? lib.trivial.release
}:

let

  branchMap = {
    "19.03" = ./release-19.03.json;
    "19.09" = ./master.json;
  };

  getOrAbort = err: key: attrs:
    if builtins.hasAttr key attrs
    then builtins.getAttr key attrs
    else builtins.abort err;

  branch =
    let
      err = "No Home Manager branch available for Nixpkgs ${version}";
    in
      getOrAbort err version branchMap;

in

fetchFromGitLab (
  {
    name = "home-manager-${version}";
  }
  // builtins.fromJSON (builtins.readFile branch)
)

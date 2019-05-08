{ callPackage, lib, fetchFromGitHub, ... } @ args:

let
  stable = import ./stable.nix;
  stableArgs = lib.attrNames (lib.functionArgs stable);
  oArgs = lib.filterAttrs (a: _: lib.elem a stableArgs) args;
in (callPackage stable oArgs).overrideAttrs (o: {
  pname = "vita-pkg2zip-unstable";
  version = "2018-07-15";

  src = fetchFromGitHub {
    owner = "mmozeiko";
    repo = "pkg2zip";
    rev = "9222c4e00235dfe7914e9db0cc352da07e63d9f9";
    sha256 = "1zz3vi12c2c4d48vvvkdl66fx5mdszcnv7lwwlgi4b8lfn1gvkr9";
  };
})

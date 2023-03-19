{ newScope }:
let
  callPackage = newScope testPkgs;
  testPkgs = {
    testLib = callPackage ./lib.nix { };
  };
in
{
  v1 = callPackage ./tests-v1 { inherit callPackage; };
  v2 = callPackage ./tests-v2 { inherit callPackage; };
}

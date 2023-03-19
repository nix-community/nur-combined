{ lib, npmlock2nix, testLib }:
let
  inherit (testLib) noSourceOptions;
  i = npmlock2nix.v2.internal;

  specRef = {
    resolved = "github:tmcw/leftpad#db1442a0556c2b133627ffebf455a78a1ced64b9";
    version = "0.0";
  };
  specGitRef = {
    resolved = "leftpad@github:tmcw/leftpad#db1442a0556c2b133627ffebf455a78a1ced64b9";
    version = "0.0";
  };
  specGitFull = {
    resolved = "git+ssh://git@github.com/tmcw/leftpad.git#db1442a0556c2b133627ffebf455a78a1ced64b9";
    version = "0.0";
  };
in
(testLib.runTests {
  testGhSourceRef = {
    expr =
      let
        version = (i.patchPackage noSourceOptions "leftpad" specRef).resolved;
      in
      lib.hasPrefix "file:///nix/store" version;
    expected = true;
  };
  testGhSourceGitRef = {
    expr =
      let
        version = (i.patchPackage noSourceOptions "leftpad" specGitRef).resolved;
      in
      lib.hasPrefix "file:///nix/store" version;
    expected = true;
  };
  testGhSourceGitRefFull = {
    expr =
      let
        version = (i.patchPackage noSourceOptions "leftpad" specGitFull).resolved;
      in
      lib.hasPrefix "file:///nix/store" version;
    expected = true;
  };
})

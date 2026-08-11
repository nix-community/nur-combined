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
  specWithGhDependencies = {
    resolved = "git+ssh://git@github.com/tmcw/leftpad.git#db1442a0556c2b133627ffebf455a78a1ced64b9";
    version = "0.0";
    dependencies = {
      utf8 = "^2.1.1";
      "bignumber.js" = "github:frozeman/bignumber.js-nolookahead";
    };
  };
  specWithPeerDependency = {
    inherit (specRef) resolved version;
    peerDependencies = {
      "@babel/core" = "^7.11.5";
      react = "^16.8.0 || ^17.0.0 || ^18.0.0";
      react-dom = "^16.8.0 || ^17.0.0 || ^18.0.0";
      require-from-string = "^2.0.2";
    };
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
  testPatchDepRegistry = {
    expr =
      let
        res = (i.patchPackage noSourceOptions "node_modules/yallist" {
          version = "4.0.0";
          resolved = "https://registry.npmjs.org/yallist/-/yallist-4.0.0.tgz";
          integrity = "sha512-3wdGidZyq5PB084XLES5TpOSRA3wjXAlIWMhum2kRcv/41Sn2emQ0dycQW4uZXLejwKvg6EsvbdlVL+FYEct7A==";
        });
      in
      [ (res.version == "4.0.0") (lib.hasPrefix "file:///nix/store" res.resolved) (res.integrity == "sha512-3wdGidZyq5PB084XLES5TpOSRA3wjXAlIWMhum2kRcv/41Sn2emQ0dycQW4uZXLejwKvg6EsvbdlVL+FYEct7A==") ];
    expected = [ true true true ];
  };
  testPatchDepRegistryWithQueryString = {
    expr =
      let
        res = (i.patchPackage noSourceOptions "node_modules/@rjsf/bootstrap-5" {
          version = "4.2.0";
          resolved = "https://github.com/nurikk/fileshare/blob/main/rjsf-bootstrap-5-4.2.0.tgz?raw=true";
          integrity = "sha512-gHwtGSeteSl3LiSOk+rIENiVjI7yaMTYcxqroXZxErstz/5WcZV5Wme+8XCYBB7yLhMiWPvNlDS9Nr4urADIdQ==";
        });
      in
      [ (res.version == "4.2.0") (lib.hasPrefix "file:///nix/store" res.resolved) (lib.hasSuffix ".tgz" res.resolved) (res.integrity == "sha512-gHwtGSeteSl3LiSOk+rIENiVjI7yaMTYcxqroXZxErstz/5WcZV5Wme+8XCYBB7yLhMiWPvNlDS9Nr4urADIdQ==") ];
    expected = [ true true true true ];
  };
  testPatchDepGithub = {
    expr =
      let
        res = (i.patchPackage noSourceOptions "node_modules/leftpad" {
          version = "0.0.1";
          resolved = "git+ssh://git@github.com/tmcw/leftpad.git#db1442a0556c2b133627ffebf455a78a1ced64b9";
          integrity = "sha512-8NCRwDs07XJJnyO7d6fVbrKjpW1nkbH0dFH5v2/U7md4+4y2hL8+S9OpRqY54W22Dq45yFKuVUYmLlrjGeFLOw==";
          license = "BSD-3-Clause";
        });
      in
      [ (lib.hasPrefix "file:///nix/store" res.resolved) (res.integrity == null) ];
    expected = [ true true ];
  };
  testSpecWithGhDependencies = {
    expr =
      let
        result = (i.patchPackage noSourceOptions "leftpad" specWithGhDependencies);
      in
      [
        (lib.hasPrefix "file:///nix/store" result.resolved)
        (result.dependencies.utf8 == "^2.1.1")
        (result.dependencies."bignumber.js" == "*")
      ];
    expected = [ true true true ];
  };
  testSpecWithPeerDependency = {
    expr =
      let
        result = (i.patchPackage noSourceOptions "leftpad" specWithPeerDependency);
      in
      result ? peerDependencies;
    expected = false;
  };
})

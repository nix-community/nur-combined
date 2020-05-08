{ pkgs, lib, nixTestRunner }:

rec {
  # I use this to keep individual features also importable independently
  # of other code in this NUR repo.
  inherit (pkgs.callPackage ./rerun-fixed.nix {}) rerunOnChange;

  /*
   Run tests. See docs in nix-test-runner/default.nix.
  */
  runTests =
    let package = nixTestRunner;
        nixTestRunnerLib = pkgs.callPackage ./nix-test-runner/default.nix {};
    in
    {
      name ?
          if testFile != null
          then "nix-tests-${builtins.baseNameOf testFile}"
          else "nix-tests"
      , testFile ? null
      , tests ? import testFile
      , alwaysPretty ? false
      , nixTestRunner ? package
    }:

    nixTestRunnerLib.runTests { inherit name testFile tests alwaysPretty nixTestRunner; };
}


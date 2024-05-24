{ branch ? "mainline", libsForQt5, fetchFromGitea }:
let
  inherit libsForQt5 fetchFromGitea;
in {
  mainline = libsForQt5.callPackage ./base.nix rec {
    pname = "suyu-mainline";
    version = "v0.0.3";
    branchName = branch;
    src = fetchFromGitea {
      domain = "git.suyu.dev";
      owner = "suyu";
      repo = "suyu";
      rev = "v0.0.3";
      hash = "sha256-wLUPNRDR22m34OcUSB1xHd+pT7/wx0pHYAZj6LnEN4g=";
      fetchSubmodules = true;
    };
  };
}.${branch}


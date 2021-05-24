{ branch ? "mainline", libsForQt5, fetchFromGitHub }:
let
  inherit libsForQt5 fetchFromGitHub;
in {
  mainline = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-mainline";
    version = "633";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "yuzu-emu";
      repo = "yuzu-mainline";
      rev = "mainline-0-${version}";
      sha256 = "1zq20dd6x3kk179ls7y3mc5rj9vr73qs12bdj52bl3kscphxybf1";
      fetchSubmodules = true;
    };
  };
  early-access = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-ea";
    version = "1704";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "pineappleEA";
      repo = "pineapple-src";
      rev = "EA-${version}";
      sha256 = "15a5kbgg5hha5v7wc54ypyyiq1ddimz7fc1x7sic6f98sirzcf7b";
      fetchSubmodules = true;
    };
  };
}.${branch}

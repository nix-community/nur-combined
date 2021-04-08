{ branch ? "mainline", libsForQt5, fetchFromGitHub }:
let
  inherit libsForQt5 fetchFromGitHub;
in {
  mainline = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-mainline";
    version = "585";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "yuzu-emu";
      repo = "yuzu-mainline";
      rev = "mainline-0-${version}";
      sha256 = "0fnb4h5m3n61lpfscbp0g7128mz2fx919zc3h45gpi4pv0sxkfaw";
      fetchSubmodules = true;
    };
  };
  early-access = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-ea";
    version = "1567";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "pineappleEA";
      repo = "pineapple-src";
      rev = "EA-${version}";
      sha256 = "07l4wnb755ql2djag0qk5scpyg1vixddz4jpxjg2w342gsvhk1ia";
      fetchSubmodules = true;
    };
  };
}.${branch}

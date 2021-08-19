{ branch ? "mainline", libsForQt5, fetchFromGitHub }:
let
  inherit libsForQt5 fetchFromGitHub;
in {
  mainline = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-mainline";
    version = "720";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "yuzu-emu";
      repo = "yuzu-mainline";
      rev = "mainline-0-${version}";
      sha256 = "0nks7yblznclccnf4diw7y74k1apax4lfla8zahlsr1afxbcda9q";
      fetchSubmodules = true;
    };
  };
  early-access = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-ea";
    version = "1997";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "pineappleEA";
      repo = "pineapple-src";
      rev = "EA-${version}";
      sha256 = "1jy9s63zcwffx0i1c66nmv5lffj50wcmqp4gnsxlvnwmyl5wfwn6";
      fetchSubmodules = true;
    };
  };
}.${branch}

{ branch ? "mainline", libsForQt5, fetchFromGitHub }:
let
  inherit libsForQt5 fetchFromGitHub;
in {
  mainline = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-mainline";
    version = "741";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "yuzu-emu";
      repo = "yuzu-mainline";
      rev = "mainline-0-${version}";
      sha256 = "0caajkzh9nidk7p4f65f3m3j8scn7z411qm19n1gccngapxvxqxf";
      fetchSubmodules = true;
    };
  };
  early-access = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-ea";
    version = "2038";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "pineappleEA";
      repo = "pineapple-src";
      rev = "EA-${version}";
      sha256 = "120lkb3pxxxjnjkl382h9dccf67rwm7yqmi9a0ajzw07v88xl5h0";
      fetchSubmodules = true;
    };
  };
}.${branch}

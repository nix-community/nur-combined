{ branch ? "mainline", libsForQt5, fetchFromGitHub }:
let
  inherit libsForQt5 fetchFromGitHub;
in {
  mainline = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-mainline";
    version = "713";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "yuzu-emu";
      repo = "yuzu-mainline";
      rev = "mainline-0-${version}";
      sha256 = "1bmnvvy58pgp5c8g826yayiyprl5l4q6vm33llridh346rcqx3x8";
      fetchSubmodules = true;
    };
  };
  early-access = libsForQt5.callPackage ./base.nix rec {
    pname = "yuzu-ea";
    version = "1991";
    branchName = branch;
    src = fetchFromGitHub {
      owner = "pineappleEA";
      repo = "pineapple-src";
      rev = "EA-${version}";
      sha256 = "1j1sf1rb5h83s4k9wgy8zv0xj6y09ik3hsxvdf157y376b8azq84";
      fetchSubmodules = true;
    };
  };
}.${branch}

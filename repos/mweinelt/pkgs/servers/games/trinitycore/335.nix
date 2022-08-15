{ callPackage, pkgs, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.22081";
  commit = "c04fe4974b9403f555d0d405aa4d3f4f1f02eb65";
  branch = "3.3.5";
  sha256 = "sha256-rKIjUNofQbRNA0x4CZ0rv/tl17yA8CCjnMrp1Y93d44=";
  boost = pkgs.boost17x;
})

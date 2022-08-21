{ callPackage, pkgs, fetchpatch, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB927.22082";
  commit = "0eff4ec7df6d34db28e09582f3e2a257bc7d35b0";
  sha256 = "sha256-T15BVaT5fO9Ixa09j7tvEFE4dALmby9UnhcKPzffVJ4=";
  boost = pkgs.boost17x;
})

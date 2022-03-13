{ callPackage, pkgs, fetchpatch, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB920.22031";
  commit = "85b15a4b8c798f0bcb190a5481d624e6eb091e67";
  sha256 = "sha256-q5H3J4C5XgtFhifB4YExmhT67oMCOSZpXoxtPnfreaE=";
  boost = pkgs.boost17x;
})

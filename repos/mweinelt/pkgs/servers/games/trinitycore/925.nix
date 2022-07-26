{ callPackage, pkgs, fetchpatch, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB925.22071";
  commit = "ce25d51b4c56110decdfde0f385fb222cb09c457";
  sha256 = "sha256-XyScxgfdx5Ft4oCQ1VcMud70D+GMCgbJpGvYK0KXnlU=";
  boost = pkgs.boost17x;
})

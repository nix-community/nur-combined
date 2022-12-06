{ callPackage, pkgs, fetchpatch, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB927.22111";
  commit = "85205d8ca5d41e4eca09619ebf46d92e7b925aaa";
  sha256 = "sha256-z+ERwiS9eZ+lapSbEWEMUmQ1wRjBqkpAfp8vWCrsR+g=";
  boost = pkgs.boost17x;
})

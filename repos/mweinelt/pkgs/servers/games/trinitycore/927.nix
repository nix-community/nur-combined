{ callPackage, pkgs, fetchpatch, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB927.22111";
  commit = "85205d8ca5d41e4eca09619ebf46d92e7b925aaa";
  sha256 = "sha256-jPllqqVth1CqyYdS0u6OFD7WvOfNnpJGqSV1GUWekqY=";
  boost = pkgs.boost17x;
})

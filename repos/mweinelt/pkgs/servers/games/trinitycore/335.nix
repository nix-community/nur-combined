{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21081";
  commit = "08d5290080aaef2b8f0c06122c158c2d238f4885";
  branch = "3.3.5";
  sha256 = "0x344sm0g1189v09cjnzijgjqk724r89nzjgh4w7332fji6km6p1";
})

{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  owner = "The-Cataclysm-Preservation-Project";
  version = "TDB434.20091";
  sha256 = "065ihvcf8nil2sgnfrhi9fnlz0m2ni4fl532y21jxjyyzazih4r5";
})

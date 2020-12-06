{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  owner = "The-Cataclysm-Preservation-Project";
  version = "TDB434.20091";
  commit = "3e5ff77e0dcdd77665bb62f5d7988ac65119a44f";
  sha256 = "065ihvcf8nil2sgnfrhi9fnlz0m2ni4fl532y21jxjyyzazih4r5";
})

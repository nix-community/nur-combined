{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21051";
  commit = "f418631de0c193772e24f379db5aafcc01f3fb6a";
  branch = "3.3.5";
  sha256 = "0845nh9vc6pajrbknnmas9ibylyasj386qxza3gcningp356c45m";
})

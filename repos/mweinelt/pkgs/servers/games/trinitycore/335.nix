{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.22021";
  commit = "cb8b06e836f2e4fa988caf564fdfa5c735419bfb";
  branch = "3.3.5";
  sha256 = "sha256-CVA7ceWS8ISJ8fXadkxFg4hLPi7p2Ebdfxwo/EXCPfs=";
})

{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21021";
  commit = "271ab4193a2e8e7d66f5ecc06ac89b73f60ac846";
  branch = "3.3.5";
  sha256 = "1lr6hqigm44bn7sz5i153pgz9938gszyhmdprqr4zygih1rv0kr6";
})

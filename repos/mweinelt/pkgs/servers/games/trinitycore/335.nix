{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21071";
  commit = "a47926ceab7091dd0c06b6bb16a0d1f64bd30a63";
  branch = "3.3.5";
  sha256 = "1n1jv9bgf9j69mqvhnhk7x4x821mq3dp63dafh76n7g23k2jaq6x";
})

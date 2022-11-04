{ callPackage, pkgs, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.22101";
  commit = "69dda649c43caf9c96318ef822b82c509ca5516d";
  branch = "3.3.5";
  sha256 = "sha256-2wguCkZLSphvAn0uVg3zhHa556MCi1goKUjZd6MGboQ=";
  boost = pkgs.boost17x;
})

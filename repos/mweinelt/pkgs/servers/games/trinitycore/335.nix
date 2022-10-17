{ callPackage, pkgs, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.22101";
  commit = "69dda649c43caf9c96318ef822b82c509ca5516d";
  branch = "3.3.5";
  sha256 = "sha256-/xfszT6dORFklxvz53RDuthgeR/6auzvpUcHvyl48GM=";
  boost = pkgs.boost17x;
})

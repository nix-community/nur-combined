{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21011";
  commit = "0b7b7f10f90eb5ef25c47749455572bcaa662d98";
  branch = "3.3.5";
  sha256 = "145sf7wr2jr4ja2x9p75sxrxvybbvv3v4g876gx7nf42z1d8bp5f";
})

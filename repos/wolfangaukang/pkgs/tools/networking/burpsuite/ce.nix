{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  url = "community";
  bin = "";
  type = "Community";
  hash = "sha256-mpOG8sx+L+/kwgB3X9ALOvq+Rx1GC3JE2G7yVt1iQYg=";
})

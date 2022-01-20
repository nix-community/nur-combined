{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  flavor = "classic";
  rev = "10f4071d75616a776b84253f2f851a84714cf068";
  hash = "sha256:03bcyva4d3ns5la00743yi77znvz2kfafm42vc9hg4ysz70dgsmd";
})

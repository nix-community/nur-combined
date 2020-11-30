{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB837.20101";
  sha256 = "0ji9jz4pn9jfl2mhy6ijzrkkfznzl8j7cbzdpzwkgdnla47xis9h";
})

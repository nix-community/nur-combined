{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB837.20101";
  commit = "f0a87e11f2668fea1eeb453a76ac03520d109029";
  sha256 = "0ji9jz4pn9jfl2mhy6ijzrkkfznzl8j7cbzdpzwkgdnla47xis9h";
})

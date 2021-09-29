{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB910.21081";
  commit = "b9ffac3afa485bff66265a3703604d15c78228d1";
  sha256 = "0gmhvf2nacahpjpl83prad6p2pklhsjfdb7rsk939l4jpv5dcbhb";
})

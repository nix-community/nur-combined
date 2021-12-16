{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21121";
  commit = "81da3d947cfab9356bfbe4bbd68267efb10192b5";
  branch = "3.3.5";
  sha256 = "1q1mgqr6gfqp9vgsd10nd19ippidhwfisms4gg0sayshdni8filv";
})

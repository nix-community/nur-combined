{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB910.21101";
  commit = "251ad7f8a838c0de1495b351ad6bead2e5968896";
  sha256 = "1spb8vx1b75hrchh487rl3zajq6mrqjzb617g8cn4zif3bkzb8qr";
})

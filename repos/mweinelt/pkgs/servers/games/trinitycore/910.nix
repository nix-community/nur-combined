{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB910.21101";
  commit = "251ad7f8a838c0de1495b351ad6bead2e5968896";
  sha256 = "1n5nsdxqpg4dbf4g8hgjiva751brqkph72vivs501r0r9pw8hp03";
})

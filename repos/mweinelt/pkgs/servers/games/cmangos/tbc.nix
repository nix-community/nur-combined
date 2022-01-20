{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  flavor = "tbc";
  rev = "ab0ac36cfe5f51d71c4b6030e82c181d46118d43";
  hash = "sha256:1f3andshx4vkag0dm7a2gwq74849m755n599a4k77wsz0kva08cf";
})

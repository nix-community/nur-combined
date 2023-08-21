{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  url = "community";
  bin = "";
  type = "Community";
  hash = "sha256-2ZnmBV/8yOqE7uwbKtmsHXKuEx+SBiqyffqh34Iwt+U=";
})

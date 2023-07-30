{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  url = "pro";
  bin = "-pro";
  type = "Professional";
  hash = "sha256-XvMR/KH17GHDz4mdalUD+LG5JfNkGbtqpPXJpcJKBEU=";
})

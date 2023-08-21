{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  url = "pro";
  bin = "-pro";
  type = "Professional";
  hash = "sha256-xcTalUY/Z89/bFCIly7PUer6ogNw8ikRYdHQpjz6sNM=";
})

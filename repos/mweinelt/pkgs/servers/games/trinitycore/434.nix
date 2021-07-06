{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  owner = "The-Cataclysm-Preservation-Project";
  version = "TDB434.21071";
  commit = "836278cff3776c9c353f6ea7bab2aaa761c22628";
  sha256 = "16drhaivdrl3ilayc6gi9g9m9vkqh6n4zm4qac6pdzivr1m5mgc2";
})

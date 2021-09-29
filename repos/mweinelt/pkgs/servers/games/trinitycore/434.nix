{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  owner = "The-Cataclysm-Preservation-Project";
  version = "TDB434.21071";
  commit = "836278cff3776c9c353f6ea7bab2aaa761c22628";
  sha256 = "0hp1blpfprw3v2avvarbns505sj1sis3pvn0pyp4a2nz8qhpg48q";
})

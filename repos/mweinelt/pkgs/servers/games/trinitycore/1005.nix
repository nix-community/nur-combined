{ callPackage, pkgs, fetchpatch, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB1005.23021";
  commit = "05581806cdb35b2cde4760f8c73da1c04ee8cf3b";
  sha256 = "sha256-Pl6yfsgt2FQaRI9EtBtvdNph5YWcDmoS/9siqt0AFLg=";
})

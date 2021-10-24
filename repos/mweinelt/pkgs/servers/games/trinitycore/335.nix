{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21101";
  commit = "ae9e5830bf759e5174e30cb28b7dda048dead971";
  branch = "3.3.5";
  sha256 = "10b40rh9wzqqf71cmrjjfby2hd24gaq0akg856ikdmxk1mrmhmj7";
})

{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB910.21081";
  commit = "b9ffac3afa485bff66265a3703604d15c78228d1";
  sha256 = "02c866zpr9ra2pw0ks7lxgx8j3lbka9nxy8f6ll85zz7ryajlz5j";
})

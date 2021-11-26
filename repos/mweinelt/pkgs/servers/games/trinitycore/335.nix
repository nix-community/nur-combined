{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21111";
  commit = "e0f1bdcd89f3c6aaa53f4c88046fce04148ab371";
  branch = "3.3.5";
  sha256 = "11fx1k3kkikach71gyaiy0yhqjsdmmw93r9rdf63873lg2aycylx";
})

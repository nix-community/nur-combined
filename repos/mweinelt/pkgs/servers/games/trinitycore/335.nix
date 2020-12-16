{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.20121";
  commit = "0b310a15466428b42c780c3c14fe7a987a08f5bb";
  branch = "3.3.5";
  sha256 = "0782z3pzhisdh1jw4kl0lpk34gjxcab6yp9910mwch9rc3z2m8c1";
})

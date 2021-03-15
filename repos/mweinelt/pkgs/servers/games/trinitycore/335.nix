{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21031";
  commit = "8c3cddd0d221b2899485d0cd9e65e0df21ec5c7a";
  branch = "3.3.5";
  sha256 = "1syalpfv5lck9r04i6ykdm457f81g3p6i0x9fd0116qvvf7wsymf";
})

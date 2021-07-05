{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB905.21071";
  commit = "6b8bb270a8b316504289dad654e5aef88cd8d27f";
  sha256 = "053fb7njnpfwfsx62pp1g1x3gcid0qw7llbr2zxjy1lda5achmzx";
})

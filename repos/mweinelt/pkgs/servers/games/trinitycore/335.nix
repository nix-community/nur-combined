{ callPackage, pkgs, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.22041";
  commit = "c0a120669dafe0688e6b7fc1e487e3dfd6220087";
  branch = "3.3.5";
  sha256 = "sha256-UOkfEYVVruJgn8zsZzu/A9Srb0uXRkvnshTo2+5vW3U=";
  boost = pkgs.boost17x;
})

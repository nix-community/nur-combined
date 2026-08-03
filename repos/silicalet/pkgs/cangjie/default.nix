{
  callPackage,
  cangjieBuildPkgs,
}:

callPackage ./source.nix { inherit cangjieBuildPkgs; }

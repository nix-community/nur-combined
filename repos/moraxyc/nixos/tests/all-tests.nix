{
  callPackage,
  ...
}:

{
  # keep-sorted start case=no numeric=yes
  airtrail = callPackage ./airtrail.nix { };
  artex = callPackage ./artex.nix { };
  ghostfolio = callPackage ./ghostfolio.nix { };
  ztnet = callPackage ./ztnet.nix { };
  # keep-sorted end
}

{
  callPackage,
  ...
}:

{
  # keep-sorted start case=no numeric=yes
  airtrail = callPackage ./airtrail.nix { };
  ghostfolio = callPackage ./ghostfolio.nix { };
  # keep-sorted end
}

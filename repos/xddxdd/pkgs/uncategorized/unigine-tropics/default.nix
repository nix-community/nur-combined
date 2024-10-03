{
  sources,
  pkgsi686Linux,
}:
pkgsi686Linux.callPackage ./package.nix { inherit sources; }

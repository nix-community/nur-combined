# Packaging adapted from https://github.com/nobbmaestro/wine-stable-nix
# Binaries: https://github.com/Gcenx/macOS_Wine_builds
{ callPackage }:
callPackage ../gcenx-wine-staging/generic.nix {
  channel = "devel";
  version = "11.14";
  hash = "sha256-Y863YzwOR30r1bEFejjlOQdtFGeN7Q9khwaTZJK1pAA=";
  appName = "Wine Devel.app";
}

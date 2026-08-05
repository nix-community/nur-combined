# Packaging adapted from https://github.com/nobbmaestro/wine-stable-nix
# Binaries: https://github.com/Gcenx/macOS_Wine_builds
{ callPackage }:
callPackage ../gcenx-wine-staging/generic.nix {
  channel = "stable";
  version = "11.0_1";
  hash = "sha256-tQ3FDsf0HVixFaa2hdTRMVujx5e9OqD0khPycDy4I4g=";
  appName = "Wine Stable.app";
}

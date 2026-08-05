# Packaging adapted from https://github.com/nobbmaestro/wine-stable-nix
# Binaries: https://github.com/Gcenx/macOS_Wine_builds
{ callPackage }:
callPackage ./generic.nix {
  channel = "staging";
  version = "11.14";
  hash = "sha256-zI/w8vleJuWR0EkJLBaJjxBxi3x0rd+/ZJitBso7q0I=";
  appName = "Wine Staging.app";
}

{
  lib,
  stdenv,
  azahar,
  fetchFromGitHub,
}:

azahar.overrideAttrs (
  final: prev: {
    pname = "azahar";
    version = "2126.0-unstable-2026-08-15";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "6673171512d5fef7b54216acbb77dc35332b71df";
      hash = "sha256-YBFKCFIuWDnhlLOAP4GNH5ViJTwrNjdu60BfmQ1Z7z4=";
      fetchSubmodules = true;
    };

    # remove unnecessary patch
    # TODO: remove this removal once nixpkgs has caught up
    patches = [ ];

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
      platforms = lib.platforms.aarch64 ++ lib.platforms.x86_64;
      # empty output
      broken = stdenv.hostPlatform.isDarwin;
    };
  }
)

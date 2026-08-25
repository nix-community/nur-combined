{
  lib,
  stdenv,
  azahar,
  fetchFromGitHub,
}:

azahar.overrideAttrs (
  final: prev: {
    pname = "azahar";
    version = "2126.1-alpha1-unstable-2026-08-24";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "083febb386aa78bbe3f96804ae38739602de526e";
      hash = "sha256-PRLQq8tL2qOXnFDH2VBCNUSj1ryOPizpdCI4E+ZWQ+8=";
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

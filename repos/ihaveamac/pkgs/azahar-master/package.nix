{
  lib,
  stdenv,
  azahar,
  fetchFromGitHub,
}:

azahar.overrideAttrs (
  final: prev: {
    pname = "azahar";
    version = "2126.1.2-unstable-2026-09-21";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "7fbe541c00f9f569d7560bdf19a891bf2f6f6af6";
      hash = "sha256-wye2xeKIsxnp+QUH0NO9tXZtQHGtZ0AGxvbFtqPxIrY=";
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

{ lib, stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2126.0-alpha2-unstable-2026-06-19";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "c9d2593c2cb4ad8e45df7abe7e02c1b42e2f260e";
    hash = "sha256-3PU5qy+60D9V1cOqjW/+cpT68oGRh7YVHqFywsfa924=";
    fetchSubmodules = true;
  };

  # remove unnecessary patch
  # TODO: remove this removal once nixpkgs has caught up
  patches = [];

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
    platforms = lib.platforms.aarch64 ++ lib.platforms.x86_64;
    # empty output
    broken = stdenv.isDarwin;
  };
})

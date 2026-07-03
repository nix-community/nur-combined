{ lib, stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2126.0-alpha2-unstable-2026-07-02";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "77cb5cecd8efa0690deca646b08c62a15839f33a";
    hash = "sha256-KaNpGzIKU89/J6qNp23E3zxSulAeGDfllKavWODkKd8=";
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

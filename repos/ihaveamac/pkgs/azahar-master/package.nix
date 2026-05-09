{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2125.1.1-unstable-2026-05-09";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "dbe7fd979f8c9e2abac5c2d0d8a8a4fe79e8f0a6";
    hash = "sha256-zIpTxQ5HUL3lrnqtiAGsZsVTTc4yaS4CTvEhhLIt2mw=";
    fetchSubmodules = true;
  };

  # remove unnecessary patch
  # TODO: remove this removal once nixpkgs has caught up
  patches = [];

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
    # empty output
    broken = stdenv.isDarwin;
  };
})

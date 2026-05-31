{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2126.0-alpha1-unstable-2026-05-30";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "4867bb2e2b8904965d9ca4f887e690f5714ab8e2";
    hash = "sha256-1t0tScVCFJcHBKUPKmz+f0pQ8Pmnd+TUh+4HdyC/2rM=";
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

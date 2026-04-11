{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2125.0.1-unstable-2026-04-09";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "b2faa299d5890a65ff979fcb379d2b20d0ca36fc";
    hash = "sha256-ctdU5NvIDIVPaQEaDADZfipMKCP1pxqPMlNCikKhhAM=";
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

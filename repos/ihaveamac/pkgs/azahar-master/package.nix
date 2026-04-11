{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2125.0.1-unstable-2026-04-11";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "e8c75b4107c94e932241de6af648f6ee212e8ddf";
    hash = "sha256-My9ub3PdyR0wshxVDZEX/CTwlD6j2DFyqP8re6STiaA=";
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

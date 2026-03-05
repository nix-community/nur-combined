{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2125.0-alpha4-unstable-2026-03-04";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "8d284aeccf2e348847f855124f958107c8c14557";
    hash = "sha256-MjI4YL3QI3cewOrqYoQGXhude1Bh3JyooqumdHqpFbM=";
    fetchSubmodules = true;
  };

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
    # empty output
    broken = stdenv.isDarwin;
  };
})

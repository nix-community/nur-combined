{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2126.0-alpha1-unstable-2026-06-04";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "c03248f1589532a44b63dcd30092458597844fe5";
    hash = "sha256-N1ecbX6QAI8BdJV9h6wclWNFh6tSn6+mC09Pq4BcI90=";
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

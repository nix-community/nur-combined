{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2125.1.1-unstable-2026-04-21";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "b3ee2d8ac5a69e3bf310a67e716606dd98c4c14c";
    hash = "sha256-vb7MzzrBip56Swcf4KP9y92FNOHY/l4rcQfN36gNDaI=";
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

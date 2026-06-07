{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2126.0-alpha1-unstable-2026-06-06";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "3dc357a8c9ff7385bea29a091e3884004b5a6fd7";
    hash = "sha256-jlRvpsLxyMSX1+ME8Vnv9uZPJbXBpsWAx2nekckrjfc=";
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

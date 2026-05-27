{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2126.0-alpha1-unstable-2026-05-17";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "ab6896a2caaaaac0b2b657f490713d2d48f08ffb";
    hash = "sha256-9OruK4dDQ+Tz3qzvhifVfF1eZHrJxoHflSIT9dL9PMI=";
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

{ lib, stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2126.0-alpha2-unstable-2026-07-09";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "0c19c33bd339827d35b15420f74e37c260e249ea";
    hash = "sha256-WIkBP9HtYXrmJ2naZsaiN4Y6Q/UNsvpWBkhSpp5IDVo=";
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

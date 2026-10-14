{
  lib,
  stdenv,
  azahar,
  fetchFromGitHub,
}:

azahar.overrideAttrs (
  final: prev: {
    pname = "azahar";
    version = "2127.0-alpha1-unstable-2026-10-13";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "73ed0e9106a5b69a8ef67d920f534150e82c6277";
      hash = "sha256-9N3mEbJfkn/MYcExMg7+iJ2YbEwFgfC3dScfTUmJ40I=";
      fetchSubmodules = true;
    };

    # remove unnecessary patch
    # TODO: remove this removal once nixpkgs has caught up
    patches = [ ];

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
      platforms = lib.platforms.aarch64 ++ lib.platforms.x86_64;
      # empty output
      broken = stdenv.hostPlatform.isDarwin;
    };
  }
)

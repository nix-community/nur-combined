{
  lib,
  stdenv,
  azahar,
  fetchFromGitHub,
}:

azahar.overrideAttrs (
  final: prev: {
    pname = "azahar";
    version = "2126.1-alpha1-unstable-2026-08-23";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "1dbd6231910ce272f346019dd866286bb1b9a53d";
      hash = "sha256-36LenlFgnwZfpI1J7mgdotMs368S02IlQAczNcHm6qk=";
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

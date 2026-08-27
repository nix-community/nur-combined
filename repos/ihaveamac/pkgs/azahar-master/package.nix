{
  lib,
  stdenv,
  azahar,
  fetchFromGitHub,
}:

azahar.overrideAttrs (
  final: prev: {
    pname = "azahar";
    version = "2126.1-rc1-unstable-2026-08-26";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "48adcefe4a3a3e301d7822a783083f685fdf8bac";
      hash = "sha256-H0+ctF2PAIjbWKViWlsrqYT7P5V7vEBM30SqonuVLSg=";
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

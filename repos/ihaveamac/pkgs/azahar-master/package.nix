{
  lib,
  stdenv,
  azahar,
  fetchFromGitHub,
}:

azahar.overrideAttrs (
  final: prev: {
    pname = "azahar";
    version = "2126.0-unstable-2026-08-17";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "fb1c1a7104fae94c670e2ea1e2a6bf09e99379c2";
      hash = "sha256-5GbBmsERMHC0vadRxtqkJrZormPXvoTiG/d57rQegbE=";
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

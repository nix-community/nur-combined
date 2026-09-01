{
  lib,
  stdenv,
  azahar,
  fetchFromGitHub,
}:

azahar.overrideAttrs (
  final: prev: {
    pname = "azahar";
    version = "2126.1-rc2-unstable-2026-09-01";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "dde53c00dc16d6436e6a0d848d6b78e8f988d9a3";
      hash = "sha256-gYQgJUfrOWvhwiNzwdlrLSRz/BIlYgvwg5yPIei9yuw=";
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

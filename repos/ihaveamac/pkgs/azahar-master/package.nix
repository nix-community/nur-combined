{
  lib,
  stdenv,
  azahar,
  ffmpeg_7-headless,
  fetchFromGitHub,
}:

(azahar.override { ffmpeg_6-headless = ffmpeg_7-headless; }).overrideAttrs (
  final: prev: {
    pname = "azahar";
    version = "2127.0-rc2-unstable-2026-11-06";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "6b4e7f2e694514fdf2f72dc20368609b7cd4912e";
      hash = "sha256-4obp19dlPP22464u/DRc3vKgpuwVnVlbcKUj0RgyghQ=";
      fetchSubmodules = true;
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
      platforms = lib.platforms.aarch64 ++ lib.platforms.x86_64;
    };
  }
)

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
    version = "2127.1-rc1-unstable-2026-11-27";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "c5177f309d4f4efac669623dddeb08e2e5262da1";
      hash = "sha256-hCEuAPZ2V1msL9/rMTJ3H6RGriSNGFu0FhzZtO7cuz4=";
      fetchSubmodules = true;
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
      platforms = lib.platforms.aarch64 ++ lib.platforms.x86_64;
    };
  }
)

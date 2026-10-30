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
    version = "2127.0-alpha3-unstable-2026-10-29";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "azahar";
      rev = "01623d2fb707317410225c0eced82e3e0c84edc1";
      hash = "sha256-d9SrI7wk4vkY5BM1vqajkkz/oa9qGb5NT/22Vapcnp4=";
      fetchSubmodules = true;
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
      platforms = lib.platforms.aarch64 ++ lib.platforms.x86_64;
    };
  }
)

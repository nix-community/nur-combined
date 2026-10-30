{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  final: prev: {
    version = "2026.10.26-unstable-2026-10-29";

    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "b77c9304e1c4220cca450c583491904daf8455af";
      hash = "sha256-9nGOcyf/chd09w0MDjmCA/rvgoj/3cLpfRizWqVW6pU=";
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
    };
  }
)

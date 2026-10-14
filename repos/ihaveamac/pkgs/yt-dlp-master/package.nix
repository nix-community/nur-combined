{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  final: prev: {
    version = "2026.08.19-unstable-2026-10-10";

    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "897341241f2bfb2439fe0367f4c7c9ccd29a3828";
      hash = "sha256-BiCa0iQA4jLZxBxOxGpcuCXH13cSt+2iOFqCeLlwI3k=";
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
    };
  }
)

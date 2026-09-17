{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  final: prev: {
    version = "2026.08.19-unstable-2026-09-16";

    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "c7fb478d21e9e59524befbe23f7801bb267fb880";
      hash = "sha256-f98zqG5ov/v6EGZxMqeXSRfKegb+XpEMQD/U5oX7F78=";
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
    };
  }
)

{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  final: prev: {
    version = "2026.11.23-unstable-2026-11-24";

    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "da452a569fb3d04091468d920f9b9e68512e0373";
      hash = "sha256-nQdQm48lsICquIz+L1wkmWFn8fPLhW08coJIozQvgxM=";
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
    };
  }
)

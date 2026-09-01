{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  final: prev: {
    version = "2026.08.19-unstable-2026-08-30";

    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "bbc809a1161d3bfca51fa36f59dda35556ee85a0";
      hash = "sha256-Wlr4N21a/oQQbxQ8n5P0aJHq9EegTTqeKzHoGC9U5zo=";
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
    };
  }
)

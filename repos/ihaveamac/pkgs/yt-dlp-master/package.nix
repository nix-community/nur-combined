{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  final: prev: {
    version = "2026.08.19-unstable-2026-08-20";

    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "81ecd58b1394793e6da9998cc19fdb45657f1685";
      hash = "sha256-W3/oBprXS30KrrdMcN932Hw3O6dEB+FC14dziOXrxDY=";
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
    };
  }
)

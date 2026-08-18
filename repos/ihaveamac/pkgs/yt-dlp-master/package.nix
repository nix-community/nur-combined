{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  final: prev: {
    version = "2026.07.04-unstable-2026-08-17";

    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "f1896c57f5ba4b92741bb509790837d6838ec99e";
      hash = "sha256-suCz+O7d6DT4ocU/et4gOfhePNaD8mrGEpbfKEOrjr4=";
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
    };
  }
)

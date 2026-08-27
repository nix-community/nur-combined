{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  final: prev: {
    version = "2026.08.19-unstable-2026-08-26";

    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "94eba4c156af080e87caf10cf8ffbea03bd17407";
      hash = "sha256-4FFg4vAC1YFUfkDOzc+URHiH7ggwa03FFLOGTNsfZR0=";
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
    };
  }
)

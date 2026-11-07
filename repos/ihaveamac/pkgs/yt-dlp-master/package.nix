{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  final: prev: {
    version = "2026.10.26-unstable-2026-11-04";

    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "412e7f0a4b0588fe884a02b344ac66a06538475b";
      hash = "sha256-a85Sd3nC0pRo6NKTWN1rMDya52NBLePGAs25DNA8P1c=";
    };

    meta = prev.meta // {
      description = prev.meta.description + " (master branch)";
    };
  }
)

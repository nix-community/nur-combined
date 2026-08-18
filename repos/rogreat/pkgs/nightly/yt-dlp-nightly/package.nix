{
  fetchFromGitHub,
  lib,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "yt-dlp-nightly";
    version = "2026.07.04-unstable-2026-08-17";

    src = fetchFromGitHub {
      inherit (previousAttrs.src) owner repo;
      rev = "f1896c57f5ba4b92741bb509790837d6838ec99e";
      hash = "sha256-suCz+O7d6DT4ocU/et4gOfhePNaD8mrGEpbfKEOrjr4=";
    };

    postPatch = ''
      version=${lib.replaceString "-" "." finalAttrs.version}
      prefix=*unstable.
      version="''${version#$prefix}"
      python devscripts/update-version.py -c nightly -r RoGreat/nur-packages $version
    ''
    + previousAttrs.postPatch;

    meta = previousAttrs.meta // {
      changelog = "https://github.com/yt-dlp/yt-dlp-nightly-builds/releases";
      maintainers = with lib.maintainers; [ RoGreat ];
    };
  }
)

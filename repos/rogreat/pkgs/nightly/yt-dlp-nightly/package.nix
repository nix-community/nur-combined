{
  fetchFromGitHub,
  lib,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "yt-dlp-nightly";
    version = "2026.07.04-unstable-2026-08-18";

    src = fetchFromGitHub {
      inherit (previousAttrs.src) owner repo;
      rev = "5d5b634d8e6b41dc2891847a5ea7a5a3f569a28c";
      hash = "sha256-s4Egvjfwj6F4iCN0y+Ax5xAg5Cuh+0qGMtBQe3NlBck=";
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

{
  fetchFromGitHub,
  lib,
  yt-dlp,
}:

yt-dlp.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "yt-dlp-nightly";
    version = "2026.07.04-unstable-2026-08-16";

    src = fetchFromGitHub {
      inherit (previousAttrs.src) owner repo;
      rev = "874af899e7da61d616c82a823a6865070ee4745d";
      hash = "sha256-MhRic4eOUmRO4cRJtMJ29LY6O5vcgP19fzo8zGa29LQ=";
    };

    postPatch = ''
      version=${lib.replaceString "-" "." finalAttrs.version}
      prefix=*unstable.
      version="''${version#$prefix}"
      python devscripts/update-version.py -c nightly -r NixOS/nixpkgs $version
    ''
    + previousAttrs.postPatch;

    meta = previousAttrs.meta // {
      changelog = "https://github.com/yt-dlp/yt-dlp-nightly-builds/releases";
      maintainers = with lib.maintainers; [ RoGreat ];
    };
  }
)

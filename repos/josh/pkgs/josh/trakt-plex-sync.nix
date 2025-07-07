{
  lib,
  fetchFromGitHub,
  python3Packages,
  nur,
  nix-update-script,
}:
let
  trakt-plex-sync = python3Packages.buildPythonApplication rec {
    pname = "trakt-plex-sync";
    version = "0.1.0-unstable-2025-07-07";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "trakt-plex-sync";
      rev = "7e40b1ba4e282c9d01e8ea7dd4d54c99d14c0e6f";
      hash = "sha256-6Ev88qrn0tJcsoj4u5Sl8dvkNV+/lwdrsbWYGz/Ir5I=";
    };

    pyproject = true;
    __structuredAttrs = true;

    build-system = with python3Packages; [
      hatchling
    ];

    dependencies = with python3Packages; [
      nur.repos.josh.python3-lru-cache
      plexapi
      requests
    ];

    meta = {
      description = "Sync Trakt history to Plex library";
      homepage = "https://github.com/josh/trakt-plex-sync";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "trakt-plex-sync";
    };
  };
in
trakt-plex-sync.overrideAttrs (
  _finalAttrs: previousAttrs: {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

      tests = {
        # TODO: Add --version test
        # TODO: Add --help test
      };
    };
  }
)

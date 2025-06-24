{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  imdb-trakt-sync = python3Packages.buildPythonApplication rec {
    pname = "imdb-trakt-sync";
    version = "0.1.0-unstable-2025-06-23";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "imdb-trakt-sync";
      rev = "32f322c3cb240795dc0e46eba24305b56676f34c";
      hash = "sha256-yejdWdRgBeR2anLXAVrA3zrDlXCn6YfKCid2wMnxQig=";
    };

    pyproject = true;
    __structuredAttrs = true;

    build-system = with python3Packages; [
      hatchling
    ];

    dependencies = with python3Packages; [
      click
      requests
    ];

    meta = {
      description = "Sync IMDb watchlist and ratings to Trakt";
      homepage = "https://github.com/josh/imdb-trakt-sync";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "imdb-trakt-sync";
    };
  };
in
imdb-trakt-sync.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    imdb-trakt-sync = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

      tests = {
        # TODO: Add --version test

        help =
          runCommand "test-imdb-trakt-sync-help"
            {
              __structuredAttrs = true;
              nativeBuildInputs = [ imdb-trakt-sync ];
            }
            ''
              imdb-trakt-sync --help
              touch $out
            '';
      };
    };
  }
)

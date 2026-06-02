{
  lib,
  fetchFromGitHub,
  nur,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  imdb-plex-sync = python3Packages.buildPythonApplication rec {
    pname = "imdb-plex-sync";
    version = "0.2.0";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "imdb-plex-sync";
      tag = "v${version}";
      hash = "sha256-nRGxekhGjaxU7uLAvIpB/B6+zx3ztlWkjG4kMg0yRbA=";
    };

    pyproject = true;

    build-system = with python3Packages; [
      hatchling
    ];

    dependencies = with python3Packages; [
      click
      nur.repos.josh.polars
    ];

    meta = {
      description = "Sync IMDb watchlist to Plex watchlist";
      homepage = "https://github.com/josh/imdb-plex-sync";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "imdb-plex-sync";
    };
  };
in
imdb-plex-sync.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    imdb-plex-sync = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

      tests = {
        help =
          runCommand "test-imdb-plex-sync-help"
            {
              __structuredAttrs = true;
              nativeBuildInputs = [ imdb-plex-sync ];
            }
            ''
              imdb-plex-sync --help
              touch $out
            '';
      };
    };
  }
)

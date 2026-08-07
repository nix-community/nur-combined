{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-trakt-sync";
  version = "0.1.0-unstable-2026-08-07";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-trakt-sync";
    rev = "3c0aaf35284cd4a5f15285d13e067305223963c3";
    hash = "sha256-T3zY0GFwymT15Cyy8X0LiObqGtXwiC59wyQyVIGkF+g=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
  ];

  pythonImportsCheck = [ "imdb_trakt_sync" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help =
      runCommand "test-imdb-trakt-sync-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          imdb-trakt-sync --help
          touch $out
        '';
  };

  meta = {
    description = "Sync IMDb watchlist and ratings to Trakt";
    homepage = "https://github.com/josh/imdb-trakt-sync";
    license = lib.licenses.mit;
    mainProgram = "imdb-trakt-sync";
    platforms = lib.platforms.all;
  };
})

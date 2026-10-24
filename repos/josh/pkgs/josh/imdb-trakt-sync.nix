{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-trakt-sync";
  version = "0.3.1";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-trakt-sync";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PX29BR4QwD3pW1Kof6/M03em6XATMtuLzSabmi/US1E=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
  ];

  pythonImportsCheck = [ "imdb_trakt_sync" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help =
      runCommand "test-imdb-trakt-sync-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
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

{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-trakt-sync";
  version = "0.2.0-unstable-2026-08-14";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-trakt-sync";
    rev = "bd9be2e98d6e51e4919ba1e62d2b28da074591ce";
    hash = "sha256-BOPVsY+hMRu8XE8lzexSaeisBHkwjGtxNIKEhR3OQYk=";
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

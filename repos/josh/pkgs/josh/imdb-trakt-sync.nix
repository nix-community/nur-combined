{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-trakt-sync";
  version = "0.1.0-unstable-2026-07-27";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-trakt-sync";
    rev = "fcabed8e2838a95a4c148d088c56e530f235ff4b";
    hash = "sha256-/GV9YunOeTJR0SAwhAUmAr57WaKgu+Zdh5tBUz3ssBs=";
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
    platforms = lib.platforms.all;
    mainProgram = "imdb-trakt-sync";
  };
})

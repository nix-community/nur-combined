{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-data";
  version = "0.1.0-unstable-2026-08-09";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-data";
    rev = "89fcfd3c7a624d1b13885eb276162031f3835597";
    hash = "sha256-G2yb0tjL/jd+bjd59IhG3IEILaYsODlOyUgP7yxhwwE=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    requests
  ];

  pythonImportsCheck = [ "imdb_data" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help =
      runCommand "test-imdb-data-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          imdb-data --help
          touch $out
        '';
  };

  meta = {
    description = "IMDB personal lists and ratings data scraper";
    homepage = "https://github.com/josh/imdb-data";
    license = lib.licenses.mit;
    mainProgram = "imdb-data";
    platforms = lib.platforms.all;
  };
})

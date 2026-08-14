{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-data";
  version = "0.2.0-unstable-2026-08-14";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-data";
    rev = "a98438dac14114f67fd2fbc581d08057474b630e";
    hash = "sha256-RAzIqObJM0xqlusdSCHhHjHngodEhmhWFUaYzyWMKaU=";
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

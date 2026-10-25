{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-data";
  version = "0.3.1";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-data";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lO4AuXBxF5Esptxx9px/YA08vKFIg93WYQVkLZFpGqk=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    requests
  ];

  pythonImportsCheck = [ "imdb_data" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help = runCommand "test-imdb-data-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
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

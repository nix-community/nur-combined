{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-data";
  version = "0.1.0-unstable-2026-07-26";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-data";
    rev = "3c508bbb35f899cbbe4e4c6479b13e201216a75a";
    hash = "sha256-cUmpi8jFKswFoBfka3xU5NLoJGUl+PJjxP8fCv9Wd2s=";
  };

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

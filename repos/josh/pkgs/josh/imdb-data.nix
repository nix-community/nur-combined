{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-data";
  version = "0.1.0-unstable-2026-07-26";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-data";
    rev = "3c508bbb35f899cbbe4e4c6479b13e201216a75a";
    hash = "sha256-cUmpi8jFKswFoBfka3xU5NLoJGUl+PJjxP8fCv9Wd2s=";
  };

  pyproject = true;
  __structuredAttrs = true;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    parsel
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
    description = "IMDB personal lists and ratings data scaper";
    homepage = "https://github.com/josh/imdb-data";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "imdb-data";
  };
})

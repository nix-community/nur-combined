{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  tmdb-index = python3Packages.buildPythonApplication {
    pname = "tmdb-index";
    version = "0-unstable-2025-07-09";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "tmdb-index";
      rev = "d74b2534325b8f2aab64dad7eeea9276ef628387";
      hash = "sha256-rk1bdIowzLmMDTFP9NR+2I66ye/eO2YLideWyU0nKvA=";
    };

    pyproject = true;

    build-system = with python3Packages; [
      hatchling
    ];

    dependencies = with python3Packages; [
      click
      polars
    ];

    meta = {
      description = "Compact TMDB external ID index";
      homepage = "https://github.com/josh/tmdb-index";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "tmdb-index";
    };
  };
in
tmdb-index.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    tmdb-index = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

      tests = {
        help =
          runCommand "test-tmdb-index-help"
            {
              __structuredAttrs = true;
              nativeBuildInputs = [ tmdb-index ];
            }
            ''
              tmdb-index --help
              touch $out
            '';
      };
    };
  }
)

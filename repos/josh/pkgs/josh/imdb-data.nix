{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  imdb-data = python3Packages.buildPythonApplication rec {
    pname = "imdb-data";
    version = "0.1.0-unstable-2025-06-30";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "imdb-data";
      rev = "a17ee616b0a2a1853a07e8e6c0c2df2aa3469911";
      hash = "sha256-Tdk6aicvateTBy6CPdB8dqF3SwlGSLPOaHtwFzOrpDU=";
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

    meta = {
      description = "IMDB personal lists and ratings data scaper";
      homepage = "https://github.com/josh/imdb-data";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "imdb-data";
    };
  };
in
imdb-data.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    imdb-data = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

      tests = {
        # TODO: Add --version test

        help =
          runCommand "test-imdb-data-help"
            {
              __structuredAttrs = true;
              nativeBuildInputs = [ imdb-data ];
            }
            ''
              imdb-data --help
              touch $out
            '';
      };
    };
  }
)

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
    version = "0.1.0-unstable-2025-08-04";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "imdb-data";
      rev = "77fa68d17277df3c188aa543c14aac6b7717562c";
      hash = "sha256-2eL1NLAV785F8ZBo3hsNiHqdTGZ+c5IzVYVvQY1BV6U=";
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

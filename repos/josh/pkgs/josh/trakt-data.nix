{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  trakt-data = python3Packages.buildPythonApplication {
    pname = "trakt-data";
    version = "0-unstable-2026-07-01";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "trakt-data";
      rev = "24f5a1c568657d949b08d190d5766b16aad5b63f";
      hash = "sha256-+Ii3O2/dQxKcx07gOdbZn3p2rPxvP7FC7m4fXlCW7qw=";
    };

    pyproject = true;
    __structuredAttrs = true;

    build-system = with python3Packages; [
      hatchling
    ];

    dependencies = with python3Packages; [
      click
      prometheus-client
      requests
    ];

    meta = {
      description = "Export Trakt data";
      homepage = "https://github.com/josh/trakt-data";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "trakt-data";
    };
  };
in
trakt-data.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    trakt-data = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

      tests = {
        # TODO: Add --version test

        help =
          runCommand "test-trakt-data-help"
            {
              __structuredAttrs = true;
              nativeBuildInputs = [ trakt-data ];
            }
            ''
              trakt-data --help
              touch $out
            '';
      };
    };
  }
)

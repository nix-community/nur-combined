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
    version = "0-unstable-2025-07-22";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "trakt-data";
      rev = "bf4b35c5ecda17c98e94c2353ba32f9471c4c6ee";
      hash = "sha256-ctPp7vaA6SKXSdIBDR8iRRY2StcZ7syfuWd0f6tALDs=";
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

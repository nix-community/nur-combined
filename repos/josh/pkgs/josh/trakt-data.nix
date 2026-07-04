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
    version = "0-unstable-2026-07-04";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "trakt-data";
      rev = "8801429f6badc6548f45d9bdea83ef7edd5167f0";
      hash = "sha256-LAPCeKwBxPOQ+VFfjUNSjvrSIf/vkQqdVhBMe1jW4go=";
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

{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  skyline = python3Packages.buildPythonApplication rec {
    pname = "skyline";
    version = "0-unstable-2025-02-04";

    src = fetchFromGitHub {
      owner = "cased";
      repo = "skyline";
      rev = "ac30b0a84f2cbf1039035063fa8f466ab3f0ba65";
      hash = "sha256-60nBO1HRWHvw3LSWkLJWm2u9cs53kN0fVdDAOmq2Nzc=";
    };

    pyproject = true;
    __structuredAttrs = true;

    build-system = with python3Packages; [
      hatchling
    ];

    dependencies = with python3Packages; [
      click
      flask
      requests
      rich
      sseclient-py
    ];

    meta = {
      description = "The missing automation for creating GitHub Apps";
      homepage = "https://github.com/cased/skyline";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "skyline";
    };
  };
in
skyline.overrideAttrs (
  finalAttrs: _previousAttrs:
  let
    skyline = finalAttrs.finalPackage;
  in
  {
    passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

    passthru.tests = {
      help =
        runCommand "test-skyline-help"
          {
            __structuredAttrs = true;
            nativeBuildInputs = [ skyline ];
          }
          ''
            skyline --help
            touch $out
          '';
    };
  }
)

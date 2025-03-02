{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  gametrack-data = python3Packages.buildPythonApplication rec {
    pname = "gametrack-data";
    version = "1.0.1";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "gametrack-data";
      rev = "v${version}";
      hash = "sha256-4A1vM0DtaB+alnLnwD/Y8tdnQwAWUXH3r+Cxr4C4DaQ=";
    };

    pyproject = true;
    __structuredAttrs = true;

    build-system = with python3Packages; [
      hatchling
    ];

    meta = {
      description = "Export GameTrack data to CSV";
      homepage = "https://github.com/josh/gametrack-data";
      license = lib.licenses.mit;
      platforms = lib.platforms.darwin;
      mainProgram = "gametrack-data";
    };
  };
in
gametrack-data.overrideAttrs (
  finalAttrs: _previousAttrs:
  let
    gametrack-data = finalAttrs.finalPackage;
  in
  {
    passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

    passthru.tests = {
      # TODO: Add --version test

      help =
        runCommand "test-gametrack-data-help"
          {
            __structuredAttrs = true;
            nativeBuildInputs = [ gametrack-data ];
          }
          ''
            gametrack-data --help
            touch $out
          '';
    };
  }
)

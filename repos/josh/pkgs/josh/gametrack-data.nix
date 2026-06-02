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
    version = "2.0.2";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "gametrack-data";
      tag = "v${version}";
      hash = "sha256-Qsd/KSbKSt62I5o7LgL2+ibZBAjKPTY5NiqCNemLcC8=";
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
  finalAttrs: previousAttrs:
  let
    gametrack-data = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

      tests = {
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
    };
  }
)

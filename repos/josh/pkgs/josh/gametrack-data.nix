{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gametrack-data";
  version = "2.0.2";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "gametrack-data";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qsd/KSbKSt62I5o7LgL2+ibZBAjKPTY5NiqCNemLcC8=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    # TODO: Add --version test once upstream argparse exposes one

    help =
      runCommand "test-gametrack-data-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          gametrack-data --help
          touch $out
        '';
  };

  meta = {
    description = "Export GameTrack data to CSV";
    homepage = "https://github.com/josh/gametrack-data";
    license = lib.licenses.mit;
    mainProgram = "gametrack-data";
    platforms = lib.platforms.darwin;
  };
})

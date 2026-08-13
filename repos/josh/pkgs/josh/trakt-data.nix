{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  testers,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "trakt-data";
  version = "0-unstable-2026-08-12";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "trakt-data";
    rev = "bd5bbe5aa9318a573cf133d7dac212f73098dbe4";
    hash = "sha256-paRc6vGey38pwbkrOvUqdkQn/OFPYTTJ7okvE+r7pZQ=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    prometheus-client
    requests
  ];

  pythonImportsCheck = [ "trakt_data" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    # Upstream pyproject.toml declares 0.1.0 but the repo has no git tags, so
    # nix-update pins the snapshot base to 0; assert the reported version
    # directly and bump this when upstream's pyproject version changes
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = "0.1.0";
    };

    help =
      runCommand "test-trakt-data-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          trakt-data --help
          touch $out
        '';
  };

  meta = {
    description = "Export Trakt data";
    homepage = "https://github.com/josh/trakt-data";
    license = lib.licenses.mit;
    mainProgram = "trakt-data";
    platforms = lib.platforms.all;
  };
})

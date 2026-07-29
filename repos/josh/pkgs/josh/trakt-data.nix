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
  version = "0-unstable-2026-07-22";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "trakt-data";
    rev = "4291cef480d203b8b7362854a3f0a4d2bf4515a2";
    hash = "sha256-7JHG8ofwgsREA2hxBEqvS9z0SCs9mKwqS5mQKbNtxeI=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    prometheus-client
    requests
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = lib.lists.head (lib.strings.splitString "-unstable-" finalAttrs.version);
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
    platforms = lib.platforms.all;
    mainProgram = "trakt-data";
  };
})

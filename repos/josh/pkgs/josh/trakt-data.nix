{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "trakt-data";
  version = "0-unstable-2026-07-30";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "trakt-data";
    rev = "077a1ffa7dfd7cf801bae90437e7c0583ebe3051";
    hash = "sha256-hlCF3U1VoJor5DTQAwXNggYndIHxjAWDM+91UcFdKoQ=";
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
    version =
      runCommand "test-trakt-data-version"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          trakt-data --version | grep "^trakt-data, version "
          touch $out
        '';

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

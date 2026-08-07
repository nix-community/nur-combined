{
  lib,
  python3Packages,
  fetchFromGitHub,
  nur,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "overcast-data";
  version = "0-unstable-2026-08-05";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "overcast-data";
    rev = "c0393fb827d4b5261b704a9fad03314c6f0e99f9";
    hash = "sha256-S3i/9/iXH0AQVlGVeL2vaE906OvBylChkXy7ylSzLw0=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    beautifulsoup4
    click
    cryptography
    nur.repos.josh.python3-lru-cache
    lxml
    mutagen
    prometheus-client
    python-dateutil
    requests
  ];

  pythonImportsCheck = [ "overcast_data" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help =
      runCommand "test-overcast-data-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          overcast-data --help
          touch $out
        '';
  };

  meta = {
    description = "Overcast podcast personal data scraper";
    homepage = "https://github.com/josh/overcast-data";
    license = lib.licenses.mit;
    mainProgram = "overcast-data";
    platforms = lib.platforms.all;
  };
})

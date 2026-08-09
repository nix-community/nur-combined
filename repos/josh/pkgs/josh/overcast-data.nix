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
  version = "0-unstable-2026-08-09";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "overcast-data";
    rev = "0dd02e9dab44a0b112137d39048b60eab0727690";
    hash = "sha256-kNKf/rwlbkj5gTXrguYsPtVgaBcFss3yHvHNKC8ir6M=";
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

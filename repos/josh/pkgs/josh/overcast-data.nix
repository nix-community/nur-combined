{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "overcast-data";
  version = "0.2.0";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "overcast-data";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XGgvx/HnUgiBDB8XWszpfWBQsBR3dJq65qknXD+3dC8=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    beautifulsoup4
    click
    cryptography
    lxml
    mutagen
    prometheus-client
    python-dateutil
    requests
  ];

  pythonImportsCheck = [ "overcast_data" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help = runCommand "test-overcast-data-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
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

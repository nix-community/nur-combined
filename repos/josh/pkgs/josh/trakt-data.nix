{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "trakt-data";
  version = "0.1.1";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "trakt-data";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vdnXPwnC8/dTnYhJBXF8zSxR85IikVL1FDSzYTbgAOs=";
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

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

  };

  meta = {
    description = "Export Trakt data";
    homepage = "https://github.com/josh/trakt-data";
    license = lib.licenses.mit;
    mainProgram = "trakt-data";
    platforms = lib.platforms.all;
  };
})

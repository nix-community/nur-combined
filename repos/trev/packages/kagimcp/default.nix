{
  fetchFromGitHub,
  lib,
  nix-update-script,

  # python packages
  callPackage,
  buildPythonPackage,
  hatchling,
  setuptools,
  kagiapi ? callPackage ./kagiapi.nix { },
  mcp,
  pydantic,
}:

buildPythonPackage (final: {
  pname = "kagimcp";
  version = "0.1.5-unstable-2026-05-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "kagimcp";
    rev = "7261eac2d3bfa41ce23928628ab84435da091acb";
    hash = "sha256-I+lyGlw4/mH38DzuHRhKYyZz7I2bWKWJbIAT3sebm4g=";
  };

  build-system = [
    setuptools
    hatchling
  ];

  pythonRelaxDeps = true;
  dependencies = [
    kagiapi
    mcp
    pydantic
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "--version=branch=main"
      final.pname
    ];
  };

  meta = {
    description = "Model Context Protocol (MCP) server for Kagi Search";
    mainProgram = "kagimcp";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://github.com/kagisearch/kagimcp";
    changelog = "https://github.com/kagisearch/kagimcp/releases/tag/v${final.version}";
  };
})

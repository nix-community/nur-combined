{
  fetchFromGitHub,
  lib,
  nix-update-script,

  # python packages
  callPackage,
  buildPythonPackage,
  hatchling,
  setuptools,
  fastmcp,
  kagiapi ? callPackage ./kagiapi.nix { },
  mcp,
  pydantic,
  python-dateutil,
}:

buildPythonPackage (final: {
  pname = "kagimcp";
  version = "0.1.5-unstable-2026-05-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "kagimcp";
    rev = "7261eac2d3bfa41ce23928628ab84435da091acb";
    hash = "sha256-Pnx4riqIFLzJJY2P0VAEl6GBYjJo6gGWbt7gbLmOqmo=";
  };

  build-system = [
    setuptools
    hatchling
  ];

  pythonRelaxDeps = true;
  dependencies = [
    fastmcp
    kagiapi
    mcp
    pydantic
    python-dateutil
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

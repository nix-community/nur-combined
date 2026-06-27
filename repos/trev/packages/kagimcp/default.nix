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
  version = "0.1.5-unstable-2026-06-26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "kagimcp";
    rev = "d51dd997fdd12601888b824e4befb7965f22bac2";
    hash = "sha256-XU8Xm5Mdfj/DX2D5vcyr/v1cJJofKSGPDDeO8suMRkg=";
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

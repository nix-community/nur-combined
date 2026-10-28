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
  fastmcp-slim,
  kagiapi ? callPackage ./kagiapi.nix { },
  mcp,
  mcp_1 ? mcp,
  pydantic,
  python-dateutil,
}:
let
  # fastmcp is broken with mcp 2.x
  fastmcp' = fastmcp.override {
    fastmcp-slim = fastmcp-slim.override { mcp = mcp_1; };
  };
in
buildPythonPackage (final: {
  pname = "kagimcp";
  version = "0.1.5-unstable-2026-10-28";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "kagimcp";
    rev = "4dc1dc97ca8dead8458c7025e4fcc36d2e3d6ec4";
    hash = "sha256-SuyKFYQECdH9zfYdLBKlTdomrkxSpxOj7hFdQftHiOo=";
  };

  build-system = [
    setuptools
    hatchling
  ];

  pythonRelaxDeps = true;
  dependencies = [
    fastmcp'
    kagiapi
    mcp_1
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

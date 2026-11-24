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
  version = "0.1.5-unstable-2026-11-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "kagimcp";
    rev = "4345fc8d8870fd8f0772417f2ebe319c0a818e5b";
    hash = "sha256-kuwQAv1df2fUrCK9qc1wLzgCeSIGbLqvf7hIdYXlvQc=";
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

{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "wikipedia-mcp";
  version = "2.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Rudra-ravi";
    repo = "wikipedia-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Jm+WGUBRiDX88vcDnDOcevWHuksTamu8IWXO5ajccR0=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    fastmcp
    python-dotenv
    requests
    wikipedia-api
  ];

  optional-dependencies = with python3.pkgs; {
    dev = [
      black
      flake8
      mypy
      pytest
      pytest-asyncio
      pytest-cov
      pytest-mock
    ];
  };

  pythonImportsCheck = [
    "wikipedia_mcp"
  ];

  meta = {
    description = "Model Context Protocol (MCP) server that retrieves information from Wikipedia to provide context to LLMs";
    homepage = "https://github.com/Rudra-ravi/wikipedia-mcp";
    changelog = "https://github.com/Rudra-ravi/wikipedia-mcp/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "wikipedia-mcp";
  };
})

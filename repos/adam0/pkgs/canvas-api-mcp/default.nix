{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  python3Packages,
  # keep-sorted end
}:
python3Packages.buildPythonPackage {
  pname = "canvas-api-mcp";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "JohannsenLum";
    repo = "canvas-api-mcp";
    rev = "0cb6664fd71827c15eba34ffc5059797879be430";
    hash = "sha256-UcaeUDgblallyAYf/x0SA/xS68R+WDALMei4iFU+h9k=";
  };

  build-system = [python3Packages.hatchling];

  dependencies = with python3Packages; [
    # keep-sorted start
    fastmcp
    httpx
    pydantic
    pypdf
    python-docx
    python-pptx
    # keep-sorted end
  ];

  nativeCheckInputs = with python3Packages; [
    # keep-sorted start
    pytest-asyncio
    pytestCheckHook
    respx
    # keep-sorted end
  ];

  pythonImportsCheck = ["canvas_api_mcp"];

  meta = with lib; {
    # keep-sorted start
    description = "MCP server for Canvas LMS: curated student tools plus a full API gateway";
    homepage = "https://github.com/JohannsenLum/canvas-api-mcp";
    license = licenses.mit;
    mainProgram = "canvas-api-mcp";
    platforms = platforms.unix;
    # keep-sorted end
  };
}

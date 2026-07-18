{
  # keep-sorted start
  fetchgit,
  lib,
  python3Packages,
  # keep-sorted end
}:
python3Packages.buildPythonApplication rec {
  pname = "tangled-mcp";
  version = "0.0.14";
  pyproject = true;

  src = fetchgit {
    url = "https://tangled.org/zzstoatzz.io/tangled-mcp";
    tag = "v${version}";
    hash = "sha256-6yXDNdnKvvJ5OiROsIEaiTWEQ+dG15AZ5WyI0cAbERQ=";
  };

  build-system = with python3Packages; [
    # keep-sorted start
    hatchling
    uv-dynamic-versioning
    # keep-sorted end
  ];

  dependencies = with python3Packages; [
    # keep-sorted start
    atproto
    fastmcp
    httpx
    pydantic-settings
    python-dotenv
    websockets
    # keep-sorted end
  ];

  pythonImportsCheck = ["tangled_mcp"];

  meta = with lib; {
    # keep-sorted start
    description = "MCP server for the Tangled git collaboration platform";
    homepage = "https://tangled.org/zzstoatzz.io/tangled-mcp";
    license = licenses.unfree;
    mainProgram = "tangled-mcp";
    platforms = platforms.unix;
    # keep-sorted end
  };
}

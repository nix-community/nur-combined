{
  lib,
  python313,
  fetchFromGitHub,
}:
let
  python = python313;
  version = "0.1.8";
in
python.pkgs.buildPythonApplication {
  pname = "excel-mcp-server";
  inherit version;

  src = fetchFromGitHub {
    owner = "haris-musa";
    repo = "excel-mcp-server";
    rev = "v${version}";
    hash = "sha256-F3QIAZWbuyE2Yl3e88HD9CZvkBpeMJI/Lm6uXuUgWKg=";
  };

  pyproject = true;

  build-system = [ python.pkgs.hatchling ];

  dependencies = with python.pkgs; [
    mcp
    fastmcp
    openpyxl
    typer
  ];

  # Upstream pins fastmcp<3.0.0, but the code only ever imports `mcp.server.fastmcp`
  # (the FastMCP bundled inside the `mcp` SDK), never the standalone `fastmcp`
  # package. Relax the pin so nixpkgs's fastmcp (3.x) satisfies the wheel metadata.
  pythonRelaxDeps = [ "fastmcp" ];

  # Upstream logs to a file next to the installed package (ROOT_DIR/excel-mcp.log),
  # which is read-only in the Nix store and crashes the server at import time.
  # Log to stderr instead -- always valid for stdio MCP and needs no writable path.
  postPatch = ''
    substituteInPlace src/excel_mcp/server.py \
      --replace-fail "logging.FileHandler(LOG_FILE)" "logging.StreamHandler()"
  '';

  pythonImportsCheck = [ "excel_mcp" ];
  doCheck = false;

  meta = {
    description = "Excel MCP Server for manipulating Excel files without Microsoft Excel";
    homepage = "https://github.com/haris-musa/excel-mcp-server";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "excel-mcp-server";
  };
}

{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "freecad-mcp";
  version = "0.1.22";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "neka-nat";
    repo = "freecad-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ilz2ZFn3gTF0JY+YnV7MrIHkt/Cjk0K5iYc8DFcGZLo=";
  };

  build-system = [
    python3.pkgs.hatchling
  ];

  # `mcp[cli]` pulls in the CLI extra (typer + python-dotenv); `validators` is
  # used for `--host` validation at startup (see _validate_host).
  dependencies = [
    python3.pkgs.mcp
    python3.pkgs.python-dotenv
    python3.pkgs.typer
    python3.pkgs.validators
  ];

  pythonImportsCheck = [
    "freecad_mcp"
    "freecad_mcp.server"
  ];

  meta = {
    description = "Model Context Protocol server that lets AI assistants control FreeCAD";
    homepage = "https://github.com/neka-nat/freecad-mcp";
    changelog = "https://github.com/neka-nat/freecad-mcp/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "freecad-mcp";
  };
})

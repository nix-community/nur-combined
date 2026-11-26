{
  lib,
  fetchPypi,
  python3,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "freecad-mcp";
  version = "0.1.32";

  pyproject = true;

  src = fetchPypi {
    pname = "freecad_mcp";
    inherit (finalAttrs) version;
    hash = "sha256-40Y+R1XQDWnFHn+z8VKUSWTKhITv/3fkDdCHd69o3zU=";
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Model Context Protocol server that lets AI assistants control FreeCAD";
    homepage = "https://github.com/neka-nat/freecad-mcp";
    changelog = "https://github.com/neka-nat/freecad-mcp/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "freecad-mcp";
  };
})

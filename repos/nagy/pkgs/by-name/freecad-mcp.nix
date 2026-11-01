{
  lib,
  fetchPypi,
  python3,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "freecad-mcp";
  version = "0.1.28";

  pyproject = true;

  src = fetchPypi {
    pname = "freecad_mcp";
    inherit (finalAttrs) version;
    hash = "sha256-Bqj8YRIgqKEAPO5DfkDseQiYeIMKJma558aqS8PugrE=";
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

  # Upstream pins `certifi>=2026.10.19`, this nixpkgs carries an older release.
  pythonRelaxDeps = [
    "certifi"
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

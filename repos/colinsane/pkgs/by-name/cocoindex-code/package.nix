# CocoIndex Code: MCP server for indexing and querying codebases using CocoIndex.
# <https://github.com/cocoindex-io/cocoindex-code>
{
  lib,
  python3,
  cocoindex,
  fetchFromGitHub,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cocoindex-code";
  version = "0.2.37";
  pyVersion = "1.0.0.dev20260625";

  src = fetchFromGitHub {
    owner = "cocoindex-io";
    repo = "cocoindex-code";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Ciiix0mMtaVxBgYQrD62rR0fm1xgHFJ2beSc3wWJZtY=";
    leaveDotGit = true;  #< TODO: try this
  };

  patches = [ ./find-ccc-from-path.patch ];

  pyproject = true;

  build-system = with python3.pkgs; [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    cocoindex
  ] ++ (with python3.pkgs; [
    litellm
    mcp
    sqlite-vec
    pydantic
    numpy
    einops
    typer
    msgspec
    pathspec
    pyyaml
    questionary
    sentence-transformers
  ]);

  pythonImportsCheck = [
    "cocoindex_code"
    "cocoindex_code.cli"
  ];

  pythonRelaxDeps = [
    "cocoindex"
    "einops"
    "mcp"
    "pydantic"
    "sqlite-vec"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=unstable" ];
  };

  meta = {
    description = "MCP server for indexing and querying codebases using CocoIndex";
    homepage = "https://github.com/cocoindex-io/cocoindex-code";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "cocoindex-code";
  };
})

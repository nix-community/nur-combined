{ lib
, buildPythonApplication
, fetchFromGitHub
, hatchling
, typer
, click
, rich
, platformdirs
, readchar
, pyyaml
, packaging
, pathspec
, json5
, mcp
, pydantic
, lark
, ...
}:

buildPythonApplication rec {
  pname = "spec-kit";
  version = "1.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    rev = "v${version}";
    hash = "sha256-jP/JyCUiwQas81rTnSRrr0NGmcTboiR5rAA3O9r8Jyw=";
  };

  nativeBuildInputs = [
    hatchling
  ];

  propagatedBuildInputs = [
    typer
    click
    rich
    platformdirs
    readchar
    pyyaml
    packaging
    pathspec
    json5
    mcp
    pydantic
    lark
  ];

  pythonImportsCheck = [ "specify_cli" ];

  meta = with lib; {
    description = "Toolkit to help you get started with Spec-Driven Development";
    homepage = "https://github.com/github/spec-kit";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "specify";
    broken =
      lib.versionOlder typer.version "0.24.0"
      || lib.versionOlder mcp.version "2.2.0"
      || lib.versionOlder pydantic.version "2.13.0";
  };
}

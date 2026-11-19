{ lib
, buildPythonApplication
, callPackage
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

let
  sources = (callPackage ../../_sources/generated.nix { }).spec-kit;
in
buildPythonApplication {
  pname = "spec-kit";
  version = lib.removePrefix "v" sources.version;
  pyproject = true;

  inherit (sources) src;

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

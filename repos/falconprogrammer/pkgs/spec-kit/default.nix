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
, ...
}:

buildPythonApplication rec {
  pname = "spec-kit";
  version = "0.14.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    rev = "v${version}";
    hash = "sha256-nZZ4dwyfDKmRkGPvCxGLPbXUgfEoR7NJ0qO/4KPsKjo=";
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
  ];

  pythonImportsCheck = [ "specify_cli" ];

  meta = with lib; {
    description = "Toolkit to help you get started with Spec-Driven Development";
    homepage = "https://github.com/github/spec-kit";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "specify";
    broken = lib.versionOlder typer.version "0.24.0";
  };
}

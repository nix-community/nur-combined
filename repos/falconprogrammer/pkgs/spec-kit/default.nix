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
  version = "0.13.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    rev = "v${version}";
    hash = "sha256-YIjVPPLAPbh/H5c3Qg0sHYnX9vluz/RXhTe/RwFdlhA=";
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

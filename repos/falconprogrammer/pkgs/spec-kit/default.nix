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
  version = "1.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    rev = "v${version}";
    hash = "sha256-TMe71eazczLdK3FLnfhkIdrrXM+CK3+39y21toD5/s4=";
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

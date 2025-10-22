{ lib
, buildPythonApplication
, fetchFromGitHub
, hatchling
, typer
, rich
, httpx
, platformdirs
, readchar
, truststore
, ...
}:

buildPythonApplication rec {
  pname = "spec-kit";
  version = "0.0.78";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    rev = "v${version}";
    hash = "sha256-x+z72t0fBV4p8mR5LafpM5CdA3zoJ8iq/sO4b/nXShI=";
  };

  nativeBuildInputs = [
    hatchling
  ];

  propagatedBuildInputs = [
    typer
    rich
    httpx
    platformdirs
    readchar
    truststore
  ];

  pythonImportsCheck = [ "specify_cli" ];

  meta = with lib; {
    description = "Toolkit to help you get started with Spec-Driven Development";
    homepage = "https://github.com/github/spec-kit";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "specify";
    broken = lib.versionOlder truststore.version "0.10.4";
  };
}

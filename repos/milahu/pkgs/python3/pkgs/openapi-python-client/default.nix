{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "openapi-python-client";
  version = "0.21.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "openapi-generators";
    repo = "openapi-python-client";
    rev = "v${version}";
    hash = "sha256-INXkaSbWQuld3lv3uLQrNt7ytOqeBHl+QGjZdT0M2yE=";
  };

  nativeBuildInputs = [
    python3.pkgs.hatchling
  ];

  propagatedBuildInputs = with python3.pkgs; [
    attrs
    colorama
    httpx
    jinja2
    pydantic
    python-dateutil
    ruamel-yaml
    ruff
    shellingham
    typer
    typing-extensions
  ];

  pythonImportsCheck = [ "openapi_python_client" ];

  meta = with lib; {
    description = "Generate modern Python clients from OpenAPI";
    homepage = "https://github.com/openapi-generators/openapi-python-client";
    changelog = "https://github.com/openapi-generators/openapi-python-client/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "openapi-python-client";
  };
}

{
  lib,
  pythonOlder,
  buildPythonPackage,
  fetchFromGitHub,
  ruamel-yaml,
  aiohttp,
  aiolinkding,
  frozenlist,
  multidict,
  shellingham,
  typer,
  yarl,
  poetry-core,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "linkding-cli";
  version = "2024.09.0";
  format = "pyproject";

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "linkding-cli";
    rev = version;
    hash = "sha256-qGL5Fe8N602Euw2FD1ZiOmyhkxSgxieYR4t1aXCbGJU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "poetry-core==1.9.0" "poetry-core"
  '';

  pythonRelaxDeps = [
    "typer"
  ];

  build-system = [poetry-core];

  dependencies = [
    ruamel-yaml
    aiohttp
    aiolinkding
    frozenlist
    multidict
    shellingham
    typer
    yarl
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "linkding_cli"
  ];

  meta = with lib; {
    description = "A CLI to interface with an instance of linkding";
    homepage = "https://github.com/bachya/linkding-cli";
    license = licenses.mit;
    maintainers = with maintainers; [renesat];
  };
}

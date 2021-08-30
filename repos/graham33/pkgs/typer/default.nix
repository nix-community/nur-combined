{ lib
, buildPythonPackage
, fetchPypi
, fetchFromGitHub
, flit-core
, click
, pytestCheckHook
, shellingham
, pytest-cov
, pytest-xdist
, pytest-sugar
, coverage
, mypy
, black
, isort
}:

buildPythonPackage rec {
  pname = "typer";
  version = "0.4.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "856a954c18dc02aea5795000257e96780a06cdaf";
    sha256 = "01rx1lcv7b65sgbwpc39qqhzj3bwbpdz1azx10q431pv1syhgqkn";
  };

  propagatedBuildInputs = [ click flit-core ];

  checkInputs = [
    pytestCheckHook
    pytest-cov
    pytest-xdist
    pytest-sugar
    shellingham
    coverage
    mypy
    black
    isort
  ];
  pytestFlagsArray = [
    "--ignore=tests/test_completion/test_completion.py"
    "--ignore=tests/test_completion/test_completion_install.py"
  ];
  # TODO: restore once https://github.com/tiangolo/typer/issues/280 is resolved
  doCheck = false;

  meta = with lib; {
    homepage = "https://typer.tiangolo.com/";
    description = "Typer, build great CLIs. Easy to code. Based on Python type hints.";
    license = licenses.mit;
    maintainers = [ maintainers.winpat ];
  };
}

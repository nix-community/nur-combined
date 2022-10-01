{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools-scm
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pytest-datadir";
  version = "1.3.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "gabrielcnr";
    repo = "pytest-datadir";
    rev = "refs/tags/${version}";
    sha256 = "sha256-zv7f416GI+2E5daN33kEvFIQr/N1NpAL59Vii7W5j08=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;
  nativeBuildInputs = [ setuptools-scm ];
  checkInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "pytest_datadir" ];

  meta = with lib; {
    description = "Pytest plugin for manipulating test data directories and files";
    homepage = "https://github.com/gabrielcnr/pytest-datadir";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
  };
}

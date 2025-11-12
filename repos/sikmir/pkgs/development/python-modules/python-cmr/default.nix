{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "python-cmr";
  version = "0.13.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nasa";
    repo = "python_cmr";
    tag = "v${version}";
    hash = "sha256-yQAWmX4PsaDx/x3AdQkVIOXAH72VvJ4Ow4QaoZq4/gc=";
  };

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    python-dateutil
    requests
    typing-extensions
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    vcrpy
  ];

  disabledTestPaths = [ "tests/test_multiple_queries.py" ];

  pythonImportsCheck = [ "cmr" ];

  meta = {
    description = "Python wrapper to the NASA Common Metadata Repository (CMR) API";
    homepage = "https://github.com/nasa/python_cmr";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}

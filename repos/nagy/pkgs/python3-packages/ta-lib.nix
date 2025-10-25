{
  pkgs,
  lib,
  buildPythonPackage,
  fetchPypi,
  cython,
  numpy,
  setuptools,
  wheel,
  build,
}:

buildPythonPackage rec {
  pname = "ta-lib";
  version = "0.6.8";
  pyproject = true;

  src = fetchPypi {
    pname = "ta_lib";
    inherit version;
    hash = "sha256-OpGVKZ3519Km6dFr69a3BrDqmeS4cYZMSwNMJXfiGnc=";
  };

  buildInputs = [ pkgs.ta-lib ];

  build-system = [
    cython
    numpy
    setuptools
    wheel
  ];

  dependencies = [
    build
    numpy
  ];

  pythonImportsCheck = [
    "talib"
  ];

  meta = {
    description = "Python wrapper for TA-Lib";
    homepage = "https://pypi.org/project/TA-Lib";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nagy ];
  };
}

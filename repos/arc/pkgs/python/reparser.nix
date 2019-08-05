{ pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "ReParser";
  version = "1.4.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0nniqb69xr0fv7ydlmrr877wyyjb61nlayka7xr08vlxl9caz776";
  };

  propagatedBuildInputs = [ enum34 ];

  checkInputs = [
    pytest
    pytestrunner
    pytest-mock
    pytest-asyncio
  ];

  meta.broken = pythonPackages.python.isPy2;
}

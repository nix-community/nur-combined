{ lib
, buildPythonPackage
, fetchPypi
  # Python Inputs
, ipyvue
}:

buildPythonPackage rec {
  pname = "ipyvuetify";
  version = "1.6.1";

  # GitHub version tries to run npm (Node JS)
  src = fetchPypi {
    inherit pname version;
    sha256 = "d0cfa23ae5a012b0b4f1772a2b2c472f2cc705e9357e16fbe74bf247d2d979f1";
  };

  propagatedBuildInputs = [ ipyvue ];

  doCheck = false;  # no tests on PyPi/GitHub
  pythonImportsCheck = [ "ipyvuetify" ];

  meta = with lib; {
    description = "Jupyter widgets based on Vuetify UI Components.";
    homepage = "https://github.com/mariobuikhuizen/ipyvuetify";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}

{ lib
, buildPythonPackage
, fetchPypi
, pythonRelaxDepsHook
, pytestCheckHook
, setuptools
, httpagentparser
, cherrypy
}:
buildPythonPackage rec {
  pname = "cherrypy-cors";
  version = "1.7.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gzhM1mSnq4uat9SSb+lxOs/gvONmXuKBiaD6BLnyEtY=";
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
    pytestCheckHook
  ];
  pythonRelaxDeps = true;

  propagatedBuildInputs = [
    setuptools
    httpagentparser
    cherrypy
  ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/cherrypy/cherrypy-cors";
    license = licenses.mit;
    maintainers = with maintainers; [ jpts ];
  };
}

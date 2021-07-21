{ lib
, buildPythonPackage
, fetchPypi
, pytest
, mock
}:

buildPythonPackage rec {
  pname = "pydash";
  version = "4.7.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-p3M4hquBHjZRC0T/HefMyYAyfXAftESkss45Xm9KSoc=";
  };

  checkInputs = [
    pytest
    mock
  ];

  meta = with lib; {
    description = "The kitchen sink of Python utility libraries for doing stuff in a functional way. Based on the Lo-Dash Javascript library";
    homepage = https://github.com/dgilland/pydash;
    license = licenses.mit;
  };
}

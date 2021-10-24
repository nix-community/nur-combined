{ lib, buildPythonPackage, fetchPypi, pythonOlder
, flake8 , importlib-metadata }:
buildPythonPackage rec {
  pname = "flake8-comprehensions";
  version = "3.1.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1wr1miwdv93fs8cj5kns1rms46546g3g6k7nl7w73g6p6l53ba73";
  };

  propagatedBuildInputs = [ flake8 ] ++ lib.optionals (pythonOlder "3.8") [ importlib-metadata ];
  
  meta = with lib; {
    description = "A flake8 plugin to help you write better list/set/dict comprehensions.";
    homepage = https://pypi.org/project/flake8-comprehensions;
    license = licenses.isc;
  };
}


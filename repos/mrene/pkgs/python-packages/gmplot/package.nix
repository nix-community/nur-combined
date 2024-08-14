{ lib
, buildPythonPackage
, fetchPypi
, fetchFromGitHub
, setuptools
, wheel
, requests
}:

buildPythonPackage rec {
  pname = "gmplot";
  version = "1.4.1";
  pyproject = true;

  # src = fetchPypi {
  #   inherit pname version;
  #   hash = "sha256-z+ctJRwXtcBQQxadEhqXKFVL9luMlnYM6fq7bSacZmc=";
  # };

  src = fetchFromGitHub {
    owner = "gmplot";
    repo = "gmplot";
    rev = "8654a5a370b5ec309e1282c457eaf375c3dcb4bb";
    hash = "sha256-/1yXuO4edSsECmKFTXs7sGK60Gw6wvvqase9KlItIgc=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    requests
  ];

  pythonImportsCheck = [ "gmplot" ];

  meta = with lib; {
    description = "A matplotlib-like interface to plot data with Google Maps";
    homepage = "https://pypi.org/project/gmplot/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

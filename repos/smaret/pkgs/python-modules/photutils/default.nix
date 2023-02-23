{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, pytestCheckHook
, astropy
, astropy-extension-helpers
, cython
, numpy
, pytest-astropy
, setuptools-scm
}:

buildPythonPackage rec {
  pname = "photutils";
  version = "1.6.0";
  format = "setuptools";

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-bafxv+9fRFFhvG8/pKaulZnHJxg8T5PG5uJKrAztk3A=";
  };

  nativeBuildInputs = [
    astropy-extension-helpers
    cython
    setuptools-scm
  ];

  propagatedBuildInputs = [ astropy numpy ];

  nativeCheckInputs = [
    pytest-astropy
    pytestCheckHook
  ];

  # TODO: Fix tests
  doCheck = false;

  pythonImportsCheck = [ "photutils" ];

  meta = with lib; {
    description = "Astropy package for detection and photometry of astronomical sources.";
    homepage = "https://github.com/astropy/photutils";
    license = licenses.bsd3;
    maintainers = with maintainers; [ smaret ];
  };
}

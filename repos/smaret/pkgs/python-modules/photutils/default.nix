{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  astropy,
  astropy-extension-helpers,
  cython,
  extension-helpers,
  numpy,
  pytest-astropy,
  pytest-xdist,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "photutils";
  version = "2.2.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-61tn8zXfWUyVRgXJvPxoCMxmNhkJuJd2w8ldkgxyK8A=";
  };

  build-system = [
    cython
    extension-helpers
    setuptools
    setuptools-scm
  ];

  dependencies = [
    astropy
    numpy
    scipy
  ];

  checkInputs = [
    pytest-astropy
    pytest-xdist
    pytestCheckHook
  ];

  # Tests must be run in the build directory
  pytestFlagsArray = [ "build/lib.*/photutils" ];

  pythonImportsCheck = [ "photutils" ];

  meta = with lib; {
    changelog = "https://github.com/astropy/photutils/releases/tag/${version}";
    description = "Astropy package for detection and photometry of astronomical sources.";
    homepage = "https://photutils.readthedocs.io";
    license = licenses.bsd3;
    maintainers = with maintainers; [ smaret ];
  };
}

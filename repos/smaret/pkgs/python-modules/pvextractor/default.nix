{
  lib,
  fetchPypi,
  buildPythonPackage,
  astropy,
  matplotlib,
  scipy,
  qtpy,
  spectral-cube,
  pytestCheckHook,
  pytest-astropy,
  setuptools,
  setuptools_scm,
}:

buildPythonPackage rec {
  pname = "pvextractor";
  version = "0.4";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-7WoRWTXoPm+qdycQfpYbxJ15FP7IXjMm5a32XN4eg84=";
  };

  build-system = [
    setuptools
    setuptools_scm
  ];

  dependencies = [
    astropy
    matplotlib
    scipy
    qtpy
    spectral-cube
  ];

  checkInputs = [
    pytestCheckHook
    pytest-astropy
  ];

  disabledTests = [
    # segfaults with Matplotlib 3.1 and later
    "gui"
  ];

  meta = {
    changelog = "https://github.com/radio-astro-tools/pvextractor/releases/tag/${version}";
    description = "Position-Velocity Diagram Extractor";
    homepage = "https://pvextractor.readthedocs.io";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ smaret ];
  };
}

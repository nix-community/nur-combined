{ lib
, fetchPypi
, buildPythonPackage
, astropy
, matplotlib
, scipy
, qtpy
, spectral-cube
, pytestCheckHook
, pytest-astropy
, setuptools_scm
}:

buildPythonPackage rec {
  pname = "pvextractor";
  version = "0.3";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-pU6YZ2DO9rGG4C0cPZjX4cGOTnXF0LcTQ7X/Wf2cCcM=";
  };

  propagatedBuildInputs = [ astropy matplotlib scipy qtpy spectral-cube ];

  nativeBuildInputs = [ setuptools_scm ];

  checkInputs = [ pytestCheckHook pytest-astropy ];

  disabledTests = [
    # segfaults with Matplotlib 3.1 and later
    "gui"
  ];

  meta = {
    description = "Position-Velocity Diagram Extractor";
    homepage = http://radio-astro-tools.github.io;
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ smaret ];
  };
}


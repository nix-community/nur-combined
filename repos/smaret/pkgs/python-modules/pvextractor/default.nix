{ lib
, fetchPypi
, buildPythonPackage
, astropy
, matplotlib
, scipy
, qtpy
, spectral-cube
, pytest
, pytest-astropy
, astropy-helpers
, six
}:

buildPythonPackage rec {
  pname = "pvextractor";
  version = "0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0213cy1c3vqlyv8ln8psav5sk9s4pqpkasa98538ydc1a7xg3mzx";
  };

  propagatedBuildInputs = [ astropy matplotlib scipy qtpy spectral-cube ];

  nativeBuildInputs = [ astropy-helpers ];
  
  checkInputs = [ pytest pytest-astropy ];

  # TODO: enable tests
  doCheck = false;

  meta = {
    description = "Position-Velocity Diagram Extractor";
    homepage = http://radio-astro-tools.github.io;
    # TODO: Fix build
    broken = true;
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ smaret ];
  };
}


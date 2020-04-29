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
  version = "0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "52d6795981cc5d3db68e5c8ec506cd5723ca856754b450567242c53dec4b74f4";
  };

  postPatch = ''
    substituteInPlace setup.cfg --replace "[pytest]" "[tool:pytest]"
    substituteInPlace pvextractor/pvextractor.py --replace "from astropy.extern import six" "import six"
  '';

  propagatedBuildInputs = [ astropy matplotlib scipy qtpy spectral-cube ];

  nativeBuildInputs = [ astropy-helpers ];
  
  checkInputs = [ pytest pytest-astropy ];

  # Tests are broken with Astropy > 4
  doCheck = false;

  meta = {
    description = "Position-Velocity Diagram Extractor";
    homepage = http://radio-astro-tools.github.io;
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ smaret ];
  };
}


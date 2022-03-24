{ stdenv
, fetchFromGitHub
, pythonPackages
, autoconf
, automake
, libtool
, ncurses
, hdf5
, sundials
}:

stdenv.mkDerivation rec {

  name = "astrochem";

  version = "v0.9";

  src = fetchFromGitHub {
    owner = "smaret";
    repo = "astrochem";
    rev = "v0.9";
    sha256 = "1a1yrblpibcqj17sbl2fjmgphx0xiinngxkmyxgvyvpw1dnx2v2f";
  };

  nativeBuildInputs = [ autoconf automake libtool ncurses ];

  buildInputs = [
    pythonPackages.python
    hdf5
    sundials
  ];

  propagatedBuildInputs = [
    pythonPackages.numpy
    pythonPackages.h5py
    pythonPackages.cython
    pythonPackages.matplotlib
  ];

  preConfigure = "./bootstrap";

  patchPhase = ''
    substituteInPlace src/chmconvert.py.in --replace "#!/usr/bin/env @PYTHON@" "#!@PYTHON@"
    substituteInPlace tests/python_tools_test.py.in  --replace "#!/usr/bin/env @PYTHON@" "#!@PYTHON@"
    substituteInPlace tests/astrochem_test.py.in  --replace "#!/usr/bin/env @PYTHON@" "#!@PYTHON@"
  '';

  doCheck = true;
}

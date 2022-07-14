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

  pname = "astrochem";
  version = "v0.9";

  src = fetchFromGitHub {
    owner = "smaret";
    repo = "astrochem";
    rev = "5dc0b2e71c27d03696195741437cdb695e92ff70";
    sha256 = "0qp5w3gn0v1fwqn29dvd0jqydh0v23mv8xmw1y24461q4dcn5403";
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

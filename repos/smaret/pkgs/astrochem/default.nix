{
  lib,
  stdenv,
  fetchFromGitHub,
  pythonPackages,
  autoconf,
  automake,
  libtool,
  ncurses,
  hdf5,
  sundials,
}:

stdenv.mkDerivation rec {

  pname = "astrochem";
  version = "v0.10";

  src = fetchFromGitHub {
    owner = "smaret";
    repo = "astrochem";
    rev = "v0.10";
    hash = "sha256-d2a8Nad80rdXY9waOcTfk6TDTm+cldb44tBXX4lNXFA=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    ncurses
  ];

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

  meta = with lib; {
    description = "Code to compute the abundances of chemical species in the interstellar medium";
    homepage = "https://github.com/smaret/astrochem";
    license = licenses.gpl3;
    maintainers = with maintainers; [ smaret ];
  };
}

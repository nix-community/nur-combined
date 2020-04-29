{ stdenv, fetchFromGitHub, pythonPackages, autoconf, automake, libtool, ncurses, hdf5, sundials }:

stdenv.mkDerivation rec {

  name = "astrochem";

  version = "v0.8";

  src = fetchFromGitHub {
    owner = "smaret";
    repo = "astrochem";
    rev = "ad5b1e718ade69c2193f9d5b03447ba813bf5e12";
    sha256 = "1ngbfvbb95dspg0nk8z1wsx65bpn7k1cif405zvsaalcs51ds9fc";
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

  doCheck = true;
}

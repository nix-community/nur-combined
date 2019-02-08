{ stdenv, fetchurl, fetchFromGitHub, pythonPackages, autoconf, automake, gfortran, libtool, hdf5, sundials, openblas }:

stdenv.mkDerivation rec {

  name = "astrochem";

  src = fetchFromGitHub {
    owner = "smaret";
    repo = "astrochem";
    rev = "e2a5f0d34b060983f86a6aa7acbf854970c4cb4f";
    sha256 = "0fg2rl3ika3qy55g1svcjcrki0ls2sdqaymbsk6pbilsk51qmq0p";
  };

  nativeBuildInputs = [ autoconf automake gfortran libtool ];

  buildInputs = [
    pythonPackages.python
    hdf5
    sundials
    openblas
  ];

  propagatedBuildInputs = [
    pythonPackages.numpy
    pythonPackages.h5py
    pythonPackages.cython
  ];

  preConfigure = "./bootstrap";
}

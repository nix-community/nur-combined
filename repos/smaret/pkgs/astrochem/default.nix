{ stdenv, fetchurl, fetchFromGitHub, pythonPackages, autoconf, automake, gfortran, libtool, hdf5, sundials }:

stdenv.mkDerivation rec {

  name = "astrochem";

  version = "3f8091b748a97e1a420b58ffd6f9e434ea8fae89";

  src = fetchFromGitHub {
    owner = "smaret";
    repo = "astrochem";
    rev = version;
    sha256 = "15185b6va556wynv1jfhgk6giqd26mjxbxj66xszv6gqv4ps7xza";
  };

  nativeBuildInputs = [ autoconf automake gfortran libtool ];

  buildInputs = [
    pythonPackages.python
    hdf5
    sundials
  ];

  propagatedBuildInputs = [
    pythonPackages.numpy
    pythonPackages.h5py
    pythonPackages.cython
  ];

  preConfigure = "./bootstrap";

  doCheck = true;
}

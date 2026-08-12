{
  lib
, buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
, autoconf
, automake
}:
buildPythonPackage rec {
  version = "1.0.25.0";
  pname = "libusb-package";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-4++0vvA9TSKx3cZl9g7/oaprNLnRWu8+/Xnhzc6KliI=";
  };

  buildInputs = [
    setuptools
    setuptools-scm
    autoconf
    automake
  ];
}
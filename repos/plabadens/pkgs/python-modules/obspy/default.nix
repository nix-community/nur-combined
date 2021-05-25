{ lib, buildPythonPackage, fetchPypi

, decorator, future, lxml, matplotlib, numpy, requests, scipy, sqlalchemy }:

buildPythonPackage rec {
  pname = "obspy";
  version = "1.2.2";

  src = fetchPypi {
    inherit pname version;
    extension = "zip";
    sha256 = "a0f2b0915beeb597762563fa0358aa1b4d6b09ffda49909c760b5cdf5bdc419e";
  };

  propagatedBuildInputs =
    [ decorator future lxml matplotlib numpy requests scipy sqlalchemy ];

  # TODO: fix the tests
  doCheck = false;

  meta = with lib; {
    description = "A Python Toolbox for seismology/seismological observatories";
    homepage = "https://docs.obspy.org";
    license = licenses.lgpl3;
  };

}

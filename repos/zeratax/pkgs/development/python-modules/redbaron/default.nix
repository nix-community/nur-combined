{ lib
, buildPythonPackage
, fetchPypi
, python3Packages
, baron
}:

buildPythonPackage rec {
  pname = "redbaron";
  version = "0.9.2";

  src = fetchPypi {
    inherit version pname;
    extension = "tar.gz";
    sha256 = "472d0739ca6b2240bb2278ae428604a75472c9c12e86c6321e8c016139c0132f";
  };

  patches = [
    ./python38.patch
  ];

  propagatedBuildInputs = with python3Packages; [
    baron
  ];

  doCheck = false;

  meta = with lib; {
    description = "Abstraction on top of baron, a FST for python to make writing refactoring code a realistic task.";
    homepage = "https://github.com/PyCQA/redbaron";
    license = licenses.lgpl3Plus;
  };
}

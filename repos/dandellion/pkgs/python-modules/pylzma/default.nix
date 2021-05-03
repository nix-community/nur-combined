{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "pylzma";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "074anvhyjgsv2iby2ql1ixfvjgmhnvcwjbdz8gk70xzkzcm1fx5q";
  };

  
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/opencv/opencv-python";
    description = "Unofficial pre-built CPU-only OpenCV packages for Python";
    license = licenses.mit;
  };

}

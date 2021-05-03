{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "opencv-python-headless";
  version = "4.5.1.48";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1idw1np8gq8460hzj2ly3481b7i2f1k12gpr6y3nsnkvbrsjas6i";
  };

  
  doCheck = true;

  meta = with lib; {
    homepage = "https://github.com/opencv/opencv-python";
    description = "Unofficial pre-built CPU-only OpenCV packages for Python";
    license = licenses.mit;
  };

}

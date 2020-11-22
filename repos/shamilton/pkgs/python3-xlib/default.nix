{ lib
, buildPythonPackage
, fetchPypi 
}:

buildPythonPackage rec {
  pname = "python3-xlib";
  version = "0.15";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1y43ngjmdyibbxjaj6vjjrxf7b8175rf8bhi3nf999aamvrlahnw";
  };

  doCheck = false;

  meta = with lib; {
    description = "Python3 version of python-xlib";
    license = licenses.gpl2;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

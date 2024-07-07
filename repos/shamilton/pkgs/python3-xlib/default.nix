{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "python3-xlib";
  version = "0.15";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "1y43ngjmdyibbxjaj6vjjrxf7b8175rf8bhi3nf999aamvrlahnw";
  };

  doCheck = false;

  meta = with lib; {
    description = "Python3 version of python-xlib";
    homepage = "https://github.com/simonzack/python3-xlib";
    license = licenses.gpl2Plus;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

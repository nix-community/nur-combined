{ lib
, python3Packages
, fetchurl
}:

python3Packages.buildPythonPackage rec {
  pname = "Phidget22";
  version = "1.17.20231004 ";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/ed/d0/4f530535f39f2062927c2e13bf4cd97873ec09c938112870fb26578f36eb/Phidget22-1.17.20231004.tar.gz";
    sha256 = "sha256-Om5oogObGC+Wgb87N0+dSFBlg1NJGpTDoIa2leuOXsE=";
  };

  doCheck = true;

  meta = with lib; {
    description = "Simple module with a Rect class for Pygame-like rectangular areas";
    homepage = "https://github.com/asweigart/pyrect";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

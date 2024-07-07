{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "PyRect";
  version = "0.2.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-9lFV9t+bkptnyv+9V8CUfFrlRJ07WA0XgHS/+0egm3g=";
  };

  doCheck = false;

  meta = with lib; {
    description = "Simple module with a Rect class for Pygame-like rectangular areas";
    homepage = "https://github.com/asweigart/pyrect";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

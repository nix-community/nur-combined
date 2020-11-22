{ lib
, buildPythonPackage
, fetchPypi 
}:

buildPythonPackage rec {
  pname = "PyRect";
  version = "0.1.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "00p2ykg3gh4jicjawiw97i1679yjd1clj58adfm12ap37hssfbrv";
  };

  doCheck = false;

  meta = with lib; {
    description = "Simple module with a Rect class for Pygame-like rectangular areas";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

{ lib
, buildPythonPackage
, fetchPypi 
, pyrect
}:

buildPythonPackage rec {
  pname = "PyGetWindow";
  version = "0.0.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1256s0nj9w7vyzv29klhi9lw25s07047fw9dhg6hbcyjwxal728p";
  };

  propagatedBuildInputs = [
    pyrect
  ];

  doCheck = false;

  meta = with lib; {
    description = "Simple, cross-platform module for obtaining GUI information on applications' windows";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

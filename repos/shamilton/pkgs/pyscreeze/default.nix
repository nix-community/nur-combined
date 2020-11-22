{ lib
, buildPythonPackage
, fetchPypi 
, pillow
}:

buildPythonPackage rec {
  pname = "PyScreeze";
  version = "0.1.26";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0inkan4dr413np98mr1w76vi3p2z3zg89fdh2gp8w83n848n6j92";
  };

  propagatedBuildInputs = [
    pillow
  ];

  doCheck = false;

  meta = with lib; {
    description = "Simple, cross-platform screenshot module for Python 2 and 3";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

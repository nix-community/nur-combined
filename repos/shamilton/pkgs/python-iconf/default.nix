{ lib
, buildPythonPackage
, fetchPypi
, pytest
}:
buildPythonPackage rec {

  pname = "iconf";
  version = "0.0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1dzb6yi9y4xhc10bdiv46b74yznppq1s2c8vrjaw351xs2fl7ca3";
  };

  doCheck = true;

  meta = with lib; {
    description = "Simple method used to load configuration variables from different sources";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

{ lib
, buildPythonPackage
, fetchPypi
, distro
, numpy
, pandas
, setuptools_scm
, setuptools
}:

buildPythonPackage rec {
  pname = "tabula-py";
  version = "2.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-sQuD0V5yCfz2XGTe4GS9stULBqfk4o/Jl0uSye8Uxcw=";
  };
  
  propagatedBuildInputs = [
    distro
    numpy
    pandas
    setuptools_scm
    setuptools
  ];

  doCheck = true;

  meta = with lib; {
    description = "Simple wrapper for tabula-java, read tables from PDF into DataFrame";
    homepage = "https://github.com/chezou/tabula-py";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

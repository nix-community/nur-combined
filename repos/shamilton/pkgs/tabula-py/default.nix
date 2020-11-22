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
  version = "2.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0f5qialmckw30jmd4mdw86m0zkxzfm713mzf9pvvmd0nfsrqnjxv";
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
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

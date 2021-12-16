{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "mip";
  version = "1.13.0";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-siyz+tkSaaXxOdd/wTg55XEy2QucaX7SeRz3uxT7zHo";
  };
  propagatedBuildInputs = with python3Packages; [ cffi setuptools_scm ];
  doCheck = false;

  meta = with lib; {
    description = "Collection of tools for Mixed-Integer Linear programs";
    homepage = "https://github.com/coin-or/python-mip";
    platforms = platforms.all;
    license = licenses.epl20;
    broken = false;

    longDescription = "Python-MIP: collection of Python tools for the modeling and solution of Mixed-Integer Linear programs";
  };
}

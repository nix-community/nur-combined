{ stdenv, fetchPypi, buildPythonPackage, attrs, flake8 }:

buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "flake8-bugbear";
  version = "18.8.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ccf56975f4db1d69dc1cf3598c99d768ebf95d0cad27d76087954aa399b515a";
  };

  doCheck = false;
  buildInputs = [];
  propagatedBuildInputs = [
    attrs
    flake8
  ];
  meta = with stdenv.lib; {
    homepage = "https://github.com/PyCQA/flake8-bugbear";
    license = licenses.mit;
    maintainer = with mainters; [ arobyn ];
    description = ''
      A plugin for flake8 finding likely bugs and design problems in your
      program. Contains warnings that don't belong in pyflakes and pycodestyle.
    '';
  };
}

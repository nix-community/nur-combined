{ stdenv, buildPythonPackage, fetchPypi, setuptools
, flake8, eradicate, attrs }:
buildPythonPackage rec {
  pname = "flake8-eradicate";
  version = "0.2.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0s6kbz42lnpqzigd2wh3mg8i952v96389bvmzg3xnhnswvgyk4xn";
  };

  propagatedBuildInputs = [ flake8 eradicate attrs setuptools ];
  
  meta = with stdenv.lib; {
    broken = true;
    description = "Flake8 plugin to find commented out code";
    homepage = https://pypi.org/project/flake8-eradicate;
    license = licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}


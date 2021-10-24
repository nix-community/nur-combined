{ lib, buildPythonPackage, fetchPypi
, mando, colorama, flake8-polyfill, future }:
buildPythonPackage rec {
  pname = "radon";
  version = "4.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ilbak6rr19l82yqzwvnqbpdlfrd4bg3ji9hr6dqkrj2ksa9kxr0";
  };

  propagatedBuildInputs = [ mando colorama flake8-polyfill future ];
  doCheck = false;
  
  meta = with lib; {
    description = "Code Metrics in Python";
    homepage = https://pypi.org/project/radon;
    license = licenses.mit;
  };
}


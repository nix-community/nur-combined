{ lib, buildPythonPackage, fetchPypi, pytestrunner
, flake8, six, pycodestyle }:
buildPythonPackage rec {
  pname = "flake8-print";
  version = "3.1.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0s2a765kyjdxahm4qcd44vmk8g6sh9zwvfk14jm8sl92lmcrwkrj";
  };

  nativeBuildInputs = [ pytestrunner ];
  propagatedBuildInputs = [ flake8 six pycodestyle ];
  doCheck = false;
  
  meta = with lib; {
    description = "print statement checker plugin for flake8";
    homepage = https://pypi.org/project/flake8-print;
    license = licenses.mit;
  };
}


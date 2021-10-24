{ lib, buildPythonPackage, fetchPypi, nose, setuptools
, flake8 }:
buildPythonPackage rec {
  pname = "flake8-logging-format";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1y3rlxwxk5w785jac2sz08d683w94bh2glkpmah78d0wqdzjnpya";
  };

  nativeBuildInputs = [ nose ];
  propogatedBuildInputs = [ flake8 setuptools ];
  doCheck = false;

  meta = with lib; {
    description = "Flake8 extension to validate (lack of) logging format strings";
    homepage = https://pypi.org/project/flake8-logging-format;
    license = licenses.asl20;
  };
}


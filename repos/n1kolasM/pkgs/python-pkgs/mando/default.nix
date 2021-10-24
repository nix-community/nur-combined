{ lib, buildPythonPackage, fetchPypi, six }:
buildPythonPackage rec {
  pname = "mando";
  version = "0.6.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0q6rl085q1hw1wic52pqfndr0x3nirbxnhqj9akdm5zhq2fv3zkr";
  };

  propagatedBuildInputs = [ six ];
  doCheck = false;

  meta = with lib; {
    description = "Create Python CLI apps with little to no effort at all!";
    homepage = https://pypi.org/project/mando;
    license = licenses.mit;
  };
}


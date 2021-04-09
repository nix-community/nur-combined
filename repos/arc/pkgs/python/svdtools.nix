{ lib, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "svdtools";
  version = "0.1.10";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0vj9l9s275k2cc8rffp9xq24gxp9xzf23gh70aw12fkkibqzydfs";
  };

  propagatedBuildInputs = [
    pyyaml
    click
  ];

  checkInputs = [
    pytest
    black
    flit
    isort
  ];

  meta.broken = python.isPy2;
}

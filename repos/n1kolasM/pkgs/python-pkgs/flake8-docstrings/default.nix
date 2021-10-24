{ lib, buildPythonPackage, fetchPypi
, flake8, pydocstyle }:
buildPythonPackage rec {
  pname = "flake8-docstrings";
  version = "1.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "05rpdydx1wdpfm4vpqmwq130ljmrjg17xa06cpm6fwvbxk3k2nix";
  };

  propagatedBuildInputs = [ flake8 pydocstyle ];
  
  meta = with lib; {
    description = "Flake8 lint for trailing commas.";
    homepage = https://pypi.org/project/flake8-commas;
    license = licenses.mit;
  };
}


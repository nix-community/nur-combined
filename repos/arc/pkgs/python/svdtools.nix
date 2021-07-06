{ lib, pythonPackages }:

with pythonPackages; with lib;

buildPythonPackage rec {
  pname = "svdtools";
  version = "0.1.14";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1llkhryk20h16q80wdp7csi1fp60xkjv28vdi4zlsi4k233anz9v";
  };

  postPatch = optionalString (versionOlder click.version "8.0") ''
    substituteInPlace setup.py \
      --replace 'click ~= 8.0' 'click < 9'
  '';

  propagatedBuildInputs = [
    pyyaml
    lxml
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

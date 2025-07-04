{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "ssh_known_hosts_edit";
  version = "0.2.0";
  format = "pyproject";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-IE3CeeCZdgabKK5wc18Jc2Dl83vpjxk9eu7xVAGUrSo=";
  };

  buildInputs = with python3Packages; [
    hatchling
    hatch-vcs
  ];

}

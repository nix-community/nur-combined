{ python3Packages, lib, fetchPypi }:
python3Packages.buildPythonPackage rec {
  pname = "appdata";
  version = "2.2.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version; 
    hash = "sha256-MSIkHhaJ64vjau4orzvwgP4hbjzI+rta9ngmsUmDepI=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = [];
}

{ python3Packages, lib, fetchPypi }:
python3Packages.buildPythonPackage rec {
  pname = "notctyparser";
  version = "23.6.21";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6NzyxITeow02pOGB0cm/L4bfQ1MdENVHbNFwPMnXCu8=";
  };


  build-system = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [
    feedparser
    requests
    lxml
  ];
}

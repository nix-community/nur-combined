{ lib
, buildPythonPackage
, fetchPypi
, setuptools-scm
, docker
, requests
, molecule
}:

buildPythonPackage rec {
  pname = "molecule-docker";
  version = "1.1.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1gsjc9wi6l48k1v33wjqf7y4fxzl8mqswnhjfl7zdnqhbwwk6lg1";
  };

  propagatedBuildInputs = [
    docker
    molecule
    requests
  ];

  nativeBuildInputs = [
    setuptools-scm
  ];

  pythonImportsCheck = [ "molecule_docker" ];
}

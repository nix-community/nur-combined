{
  buildPythonPackage,
  fetchPypi,
  pillow,
  torchvision,
}:

buildPythonPackage rec {
  pname = "facenet-pytorch";
  version = "2.5.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-mMxbQqSPg3wCPrkvKlcc1KxqRmh8XnG56ZtJEIcnPis=";
  };

  doCheck = false; # pypi version doesn't ship with tests

  pythonImportsCheck = [ "facenet_pytorch" ];

  propagatedBuildInputs = [
    pillow
    torchvision
  ];
}

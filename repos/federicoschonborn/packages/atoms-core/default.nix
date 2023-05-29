{ lib
, buildPythonPackage
, fetchFromGitHub
, orjson
, requests
}:

buildPythonPackage rec {
  pname = "atoms-core";
  version = "1.1.1";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "AtomsDevs";
    repo = "atoms-core";
    rev = version;
    hash = "sha256-Owf7W39IrmkHlv71618YgrgC/nhgo4oWJY0wVYEN1Tk=";
  };

  pythonPath = [
    orjson
    requests
  ];

  pythonImportsCheck = [ "atoms_core" ];

  meta = with lib; {
    description = "Atoms Core allows you to create and manage your own chroots and podman containers";
    homepage = "https://github.com/AtomsDevs/atoms-core";
    license = licenses.gpl3Only;
  };
}

{ lib
, buildPythonPackage
, fetchFromGitHub
, orjson
, requests
}:

buildPythonPackage rec {
  pname = "atoms-core";
  version = "1.1.2";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "AtomsDevs";
    repo = "atoms-core";
    rev = version;
    hash = "sha256-Z2jFagCaYDRFzzftKI+LY15lgB2KkLeoNN0w2Zpy+yY=";
  };

  pythonPath = [
    orjson
    requests
  ];

  pythonImportsCheck = [ "atoms_core" ];

  meta = {
    description = "Atoms Core allows you to create and manage your own chroots and podman containers";
    homepage = "https://github.com/AtomsDevs/atoms-core";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}

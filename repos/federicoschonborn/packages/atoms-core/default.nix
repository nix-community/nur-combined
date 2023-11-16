{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, orjson
, requests
, nix-update-script
}:

buildPythonPackage rec {
  pname = "atoms-core";
  version = "1.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AtomsDevs";
    repo = "atoms-core";
    rev = version;
    hash = "sha256-Z2jFagCaYDRFzzftKI+LY15lgB2KkLeoNN0w2Zpy+yY=";
  };

  buildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    orjson
    requests
  ];

  pythonImportsCheck = [
    "atoms_core"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Atoms Core allows you to create and manage your own chroots and podman containers";
    homepage = "https://github.com/AtomsDevs/atoms-core";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}

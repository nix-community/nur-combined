{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  aiohttp,
  cryptography,
  hatchling,
}:

buildPythonPackage rec {
  pname = "connectlife";
  version = "0.13.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "oyvindwe";
    repo = "connectlife";
    rev = "v${version}";
    hash = "sha256-WZx4nnU0sUUwIXuCtXRgf6iMVPacubHcPvEGmy64LCA=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    aiohttp
    cryptography
  ];

  pythonImportsCheck = [
    "connectlife"
  ];

  meta = with lib; {
    description = "Python library for ConnectLife API";
    homepage = "https://github.com/oyvindwe/connectlife";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "connectlife";
  };
}

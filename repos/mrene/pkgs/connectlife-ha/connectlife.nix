{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  aiohttp,
  hatchling,
}:

buildPythonPackage rec {
  pname = "connectlife";
  version = "unstable-2024-08-14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "oyvindwe";
    repo = "connectlife";
    rev = "7cef61203742cf07987d2754a3eb3c5cfab4ec58";
    hash = "sha256-2CDq3Vw+Wst2kVc7fI8RY58z0vTA/3+vnX0/CduiPck=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    aiohttp
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

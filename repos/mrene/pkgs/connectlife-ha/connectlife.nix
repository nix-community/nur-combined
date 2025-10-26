{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  aiohttp,
  hatchling,
}:

buildPythonPackage rec {
  pname = "connectlife";
  version = "0.5.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "oyvindwe";
    repo = "connectlife";
    rev = "v${version}";
    hash = "sha256-KZOOLAg6Uq8E7oqArTvw4O1vfZO08bRnODH+UZLubGU=";
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

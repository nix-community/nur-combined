{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, black
, flake8
, isort
, kornia
, opencv4
, packaging
, torch
, torchvision
}:

buildPythonPackage rec {
  pname = "lightglue";
  version = "unstable-2023-10-19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cvg";
    repo = "LightGlue";
    rev = "29f3e449efa1994758b8a16299d2816028dca65b";
    hash = "sha256-NYDAh0mOiH3Qs8XMrFkDNKm/0LDjYSDpFGpf0ojfd/A=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    kornia
    opencv4
    packaging # TODO: mv to kornia
    torch
    torchvision
  ];

  passthru.optional-dependencies = {
    dev = [
      black
      flake8
      isort
    ];
  };

  pythonImportsCheck = [ "lightglue" ];

  meta = with lib; {
    description = "LightGlue: Local Feature Matching at Light Speed (ICCV 2023";
    homepage = "https://github.com/cvg/LightGlue";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}

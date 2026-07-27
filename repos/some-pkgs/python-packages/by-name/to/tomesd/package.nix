{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, torch
}:

buildPythonPackage rec {
  pname = "tomesd";
  version = "0.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dbolya";
    repo = "tomesd";
    rev = "v${version}";
    hash = "sha256-U3LN6KmQx/ulepFxjWgYHJl5g8j1U3HIGunpjcZBcos=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    torch
  ];

  pythonImportsCheck = [ "tomesd" ];

  meta = with lib; {
    description = "Speed up Stable Diffusion with this one simple trick";
    homepage = "https://github.com/dbolya/tomesd";
    changelog = "https://github.com/dbolya/tomesd/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

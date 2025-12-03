{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pytrakt";
  version = "4.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "glensc";
    repo = "python-pytrakt";
    rev = version;
    hash = "sha256-2lLUWiAxmykdHpDytSJN1MyBP5rt5e8tRFKpOQzbS9g=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    # dataclasses # included in Python 3.7
    deprecated
    requests
    requests-oauthlib
  ];

  pythonImportsCheck = [
    #"pytrakt"
  ];

  meta = {
    description = "A Pythonic interface to the Trakt.tv REST API";
    homepage = "https://github.com/glensc/python-pytrakt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pytrakt";
  };
}

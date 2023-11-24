{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "chromecontroller";
  version = "unstable-2023-08-28";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fake-name";
    repo = "ChromeController";
    rev = "5c967531578e2f0830e3a78c5f038ff516990bca";
    hash = "sha256-S5q5/EXO5pjx82pNcu3yGCe64fJilgqhVjyAvMjj9HY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
		websocket-client
		astor
		requests
		cachetools
		docopt
  ];

  pythonImportsCheck = [ "ChromeController" ];

  meta = with lib; {
    description = "Comprehensive wrapper and execution manager for the Chrome browser using the Chrome Debugging Protocol";
    homepage = "https://github.com/fake-name/ChromeController";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    mainProgram = "chrome-controller";
  };
}

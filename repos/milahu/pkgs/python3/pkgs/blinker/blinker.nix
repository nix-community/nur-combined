{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "blinker";
  version = "1.6.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pallets-eco";
    repo = "blinker";
    rev = version;
    hash = "sha256-s74zYyExttRxHFPanw5Zqeby36Dq6aJj3IeQQGw3aes=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
  ];

  pythonImportsCheck = [ "blinker" ];

  meta = with lib; {
    description = "A fast Python in-process signal/event dispatching system";
    homepage = "https://github.com/pallets-eco/blinker";
    changelog = "https://github.com/pallets-eco/blinker/blob/${src.rev}/CHANGES.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

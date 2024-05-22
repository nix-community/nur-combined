{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "vncdotool";
  version = "1.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sibson";
    repo = "vncdotool";
    rev = "v${version}";
    hash = "sha256-QrD6z/g85FwaZCJ1PRn8CBKCOQcbVjQ9g0NpPIxguqk=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pillow
    pycryptodomex
    twisted
    zope-interface
  ];

  pythonImportsCheck = [ "vncdotool" ];

  meta = with lib; {
    description = "A command line VNC client and python library";
    homepage = "https://github.com/sibson/vncdotool";
    changelog = "https://github.com/sibson/vncdotool/blob/${src.rev}/CHANGELOG.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "vncdotool";
  };
}

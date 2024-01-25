{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "browser-debugger-tools";
  version = "6.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "scivisum";
    repo = "browser-debugger-tools";
    rev = version;
    hash = "sha256-kEDj18m5WfQs02vy6VcYFiKo7mw0IsP9NjKdaseIszQ=";
  };

  # https://github.com/scivisum/browser-debugger-tools/blob/master/setup.py
  # fix: typing not installed
  # https://github.com/scivisum/browser-debugger-tools/issues/46
  postPatch = ''
    sed -i '/"typing"/d' setup.py
  '';

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    requests
    websocket-client
  ];

  pythonImportsCheck = [ "browserdebuggertools" ];

  meta = with lib; {
    description = "A python client for the devtools protocol";
    homepage = "https://github.com/scivisum/browser-debugger-tools";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "browser-debugger-tools";
  };
}

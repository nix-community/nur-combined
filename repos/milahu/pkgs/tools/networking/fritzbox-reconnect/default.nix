{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "fritzbox-reconnect";
  version = "0.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "fritzbox-reconnect";
    rev = "9f345f18d617bc0bcb3afc8eeb82bc03ebe4f388";
    hash = "sha256-ZhyHcG0wXTmKfOZL3jIN0R9oREGqlWXWRLjsfel3KG4=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    selenium-driverless
    cdp-socket
  ];

  pythonImportsCheck = [ "fritzbox_reconnect" ];

  meta = with lib; {
    description = "get new IP address from fritzbox DSL router";
    homepage = "https://github.com/milahu/fritzbox-reconnect";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "fritzbox-reconnect";
  };
}

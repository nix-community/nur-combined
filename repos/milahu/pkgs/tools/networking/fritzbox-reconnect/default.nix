{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "fritzbox-reconnect";
  version = "0.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "fritzbox-reconnect";
    rev = version;
    hash = "sha256-A7Qj3SvgNXxqTnwVKdLcaf5YxNbuGS5Eb2SeXupTBKk=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    selenium-driverless
    cdp-socket
    psutil
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

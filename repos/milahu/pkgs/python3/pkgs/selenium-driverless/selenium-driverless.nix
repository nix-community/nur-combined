{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "selenium-driverless";
  version = "unstable-2023-10-29";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kaliiiiiiiiii";
    repo = "Selenium-Driverless";
    rev = "c207798337d07e6fd98dc44e86ed5b59f3c67f48";
    hash = "sha256-QUDAwXnH4KrwXbcIg77G5KOATlitCBUkE3V/mwzRzqk=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    cdp-socket
    numpy
    pytest
    selenium
    setuptools
    twine
  ];

  pythonImportsCheck = [ "selenium_driverless" ];

  meta = with lib; {
    description = "Undetected Selenium without usage of chromedriver";
    homepage = "https://github.com/kaliiiiiiiiii/Selenium-Driverless";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "selenium-driverless";
  };
}

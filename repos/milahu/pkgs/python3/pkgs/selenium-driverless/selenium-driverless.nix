{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "selenium-driverless";
  version = "1.6.3.3";
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
    matplotlib
    scipy
  ];

  # disable the license nag message in selenium_driverless/webdriver.py
  # the "is_first_run" file is checked in selenium_driverless/utils/utils.py
  # https://github.com/kaliiiiiiiiii/Selenium-Driverless/issues/122
  postPatch = ''
    sed -i 's/^is_first_run = .*/is_first_run = False/' src/selenium_driverless/utils/utils.py
  '';

  pythonImportsCheck = [ "selenium_driverless" ];

  meta = with lib; {
    description = "Undetected Selenium without usage of chromedriver";
    homepage = "https://github.com/kaliiiiiiiiii/Selenium-Driverless";
    license = licenses.cc-by-nc-sa-40;
    maintainers = with maintainers; [ ];
  };
}

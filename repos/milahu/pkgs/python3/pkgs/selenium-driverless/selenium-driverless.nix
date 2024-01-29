{ lib
, python3
, fetchFromGitHub
, cdp-socket
}:

python3.pkgs.buildPythonPackage rec {
  pname = "selenium-driverless";
  # grep version src/selenium_driverless/__init__.py
  version = "1.7.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kaliiiiiiiiii";
    repo = "Selenium-Driverless";
    rev = "24a3513305f833fac600ec8e31bcd5e9df955162";
    hash = "sha256-Iixv4IrxuCJKjs3tDK0Qn3fFO/frFlYcPgtsbdmoj1Q=";
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
    aiofiles
    platformdirs
  ];

  # disable the license nag message in selenium_driverless/webdriver.py
  # the "is_first_run" file is checked in selenium_driverless/utils/utils.py
  # https://github.com/kaliiiiiiiiii/Selenium-Driverless/issues/122
  postPatch = ''
    sed -i 's/^is_first_run = .*/is_first_run = False/' src/selenium_driverless/utils/utils.py
  ''
  +
  # fix warnings
  # fix: Package 'selenium_driverless.files.js' is absent from the `packages` configuration.
  # fix: Package 'selenium_driverless.files.mv3_extension' is absent from the `packages` configuration.
  ''
    substituteInPlace setup.py \
      --replace \
        "setuptools.find_packages" \
        "setuptools.find_namespace_packages" \
  ''
  ;

  pythonImportsCheck = [ "selenium_driverless" ];

  meta = with lib; {
    description = "Undetected Selenium without usage of chromedriver";
    homepage = "https://github.com/kaliiiiiiiiii/Selenium-Driverless";
    license = licenses.cc-by-nc-sa-40;
    maintainers = with maintainers; [ ];
  };
}

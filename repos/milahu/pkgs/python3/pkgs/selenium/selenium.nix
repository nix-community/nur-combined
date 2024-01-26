# based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/python-modules/selenium/default.nix

{ lib
, fetchPypi
, buildPythonPackage
, setuptools
, wheel
, certifi
, trio
, trio-websocket
, typing-extensions
, urllib3
}:

buildPythonPackage rec {
  pname = "selenium";
  version = "4.17.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1D1pcuUWhV+yQu+c5M51kFexFQcOcC57HBAy/ns42Hs=";
  };

  # relax versions
  # fix: typing-extensions~=4.9 not satisfied by version 4.8.0
  # https://github.com/SeleniumHQ/selenium/blob/trunk/py/setup.py

  # also add selenium.webdriver.common.devtools.* packages
  # fix: ModuleNotFoundError: No module named 'selenium.webdriver.common.devtools'
  # https://github.com/milahu/nixpkgs/issues/20

  postPatch = ''
    sed -i 's/[~>]=.*"/"/' setup.py
    substituteInPlace setup.py \
      --replace \
        "    'packages': [" \
        "    'packages': find_namespace_packages(where='.'), '_packages': [" \
      --replace \
        "from setuptools import setup" \
        "from setuptools import setup, find_namespace_packages" \
  '';

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    certifi
    trio
    trio-websocket
    typing-extensions
    urllib3
  ];

  pythonImportsCheck = [ "selenium" ];

  meta = with lib; {
    description = "Bindings for Selenium WebDriver";
    homepage = "https://selenium.dev/";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };

}

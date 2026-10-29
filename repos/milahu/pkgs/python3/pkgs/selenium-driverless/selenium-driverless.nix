{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchurl,
  wheel,
  cdp-socket,
  numpy,
  pytest,
  selenium,
  setuptools,
  twine,
  matplotlib,
  scipy,
  aiofiles,
  platformdirs,
}:

buildPythonPackage rec {
  pname = "selenium-driverless";
  # grep version src/selenium_driverless/__init__.py
  version = "1.9.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ttlns";
    repo = "Selenium-Driverless";
    rev = "a09684455ccb3d1bcbfebcdbdb1390354cf6e455";
    hash = "sha256-DL8h/A1CEmqY8Z7O0cNPm3ZAkUDN+0TVF9d5CrbBJ/U=";
  };

  /*
  patches = [
    # superseded by https://github.com/ttlns/Selenium-Driverless/commit/a2e101d23d5e52fc46624622e2758e45fefa6892
    # remove license nagger
    # https://github.com/ttlns/Selenium-Driverless/issues/122
    # https://github.com/milahu/selenium_driverless
    (fetchurl {
      url = "https://github.com/milahu/selenium_driverless/commit/93f02860142e1db6133cc79bff824844ab89b564.patch";
      hash = "sha256-6kibaCYogqyUWN6uJrOkzs0KmD3XU+RRsGqKXbLz4ps=";
    })
    # merged in https://github.com/ttlns/Selenium-Driverless/commit/9d3ba72a899a0ac1d3f9054b55d6f26d153fd3d5
    # fix for numpy 2
    # https://github.com/ttlns/Selenium-Driverless/pull/345
    (fetchurl {
      url = "https://github.com/milahu/selenium_driverless/commit/01e0fcf049c25e7e336bac6093caba9e43828869.patch";
      hash = "sha256-J7sqznhWVUvm/oNoMZ+LoKqbAkqs3Dnc8FY9q5u1O5o=";
    })
  ];
  */

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
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

  postPatch = ''
    echo "relaxing dependency versions"
    sed -i.bak -E "s/[~>]=[0-9.]+([\"'])/\1/g" setup.py
    diff -u setup.py.bak setup.py || true
    rm setup.py.bak
  '';

  pythonImportsCheck = [ "selenium_driverless" ];

  meta = with lib; {
    description = "Undetected Selenium without usage of chromedriver";
    homepage = "https://github.com/ttlns/Selenium-Driverless";
    # license was changed to MIT license in https://github.com/ttlns/Selenium-Driverless/commit/dd5e7e51395e96e3844f4440c4e86a2bc98e9aef
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

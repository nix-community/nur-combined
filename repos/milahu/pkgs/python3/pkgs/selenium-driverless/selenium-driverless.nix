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
    rev = "ca333fd88b0b7722ac128e08deccbb5ffbd66b39";
    hash = "sha256-wk+0W888dx62hNjZVzzVDHXMs6VNtXRBRWEM1rOe9yc=";
  };

  patches = [
    # remove license nagger
    # https://github.com/ttlns/Selenium-Driverless/issues/122
    # https://github.com/milahu/selenium_driverless
    (fetchurl {
      url = "https://github.com/milahu/selenium_driverless/commit/93f02860142e1db6133cc79bff824844ab89b564.patch";
      hash = "sha256-6kibaCYogqyUWN6uJrOkzs0KmD3XU+RRsGqKXbLz4ps=";
    })
    # fix for numpy 2
    # https://github.com/ttlns/Selenium-Driverless/pull/345
    (fetchurl {
      url = "https://github.com/milahu/selenium_driverless/commit/01e0fcf049c25e7e336bac6093caba9e43828869.patch";
      hash = "sha256-J7sqznhWVUvm/oNoMZ+LoKqbAkqs3Dnc8FY9q5u1O5o=";
    })
  ];

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
    license = licenses.cc-by-nc-sa-40;
    maintainers = with maintainers; [ ];
  };
}

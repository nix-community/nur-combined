{ lib
, python3
, fetchFromGitHub
, fetchurl
, cdp-socket
}:

python3.pkgs.buildPythonPackage rec {
  pname = "selenium-driverless";
  # grep version src/selenium_driverless/__init__.py
  version = "1.9.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kaliiiiiiiiii";
    repo = "Selenium-Driverless";
    rev = "ca333fd88b0b7722ac128e08deccbb5ffbd66b39";
    hash = "sha256-wk+0W888dx62hNjZVzzVDHXMs6VNtXRBRWEM1rOe9yc=";
  };

  patches = [
    # remove license nagger
    # https://github.com/kaliiiiiiiiii/Selenium-Driverless/issues/122
    # https://github.com/milahu/selenium_driverless
    (fetchurl {
      url = "https://github.com/milahu/selenium_driverless/commit/93f02860142e1db6133cc79bff824844ab89b564.patch";
      hash = "sha256-6kibaCYogqyUWN6uJrOkzs0KmD3XU+RRsGqKXbLz4ps=";
    })
  ];

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

  postPatch = ''
    echo "relaxing dependency versions"
    sed -i.bak -E "s/[~>]=[0-9.]+([\"'])/\1/g" setup.py
    diff -u setup.py.bak setup.py || true
    rm setup.py.bak

    # fix: find_elements returns wrong number of elements
    # https://github.com/kaliiiiiiiiii/Selenium-Driverless/issues/162
    substituteInPlace src/selenium_driverless/types/deserialize.py \
      --replace \
        "int(description[-2])" \
        "int(description[len(class_name)+1:-1])"
  '';

  pythonImportsCheck = [ "selenium_driverless" ];

  meta = with lib; {
    description = "Undetected Selenium without usage of chromedriver";
    homepage = "https://github.com/kaliiiiiiiiii/Selenium-Driverless";
    license = licenses.cc-by-nc-sa-40;
    maintainers = with maintainers; [ ];
  };
}

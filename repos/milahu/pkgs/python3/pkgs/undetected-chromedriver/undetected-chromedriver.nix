{ lib
, python3
, fetchFromGitHub
, pkgs-undetected-chromedriver
}:

python3.pkgs.buildPythonApplication rec {
  pname = "undetected-chromedriver";
  # https://pypi.org/project/undetected-chromedriver/
  version = "3.5.4";
  pyproject = true;

  passthru = {
    # patched chromedriver binary
    # usage:
    /*
      undetected_chromedriver.Chrome(
        driver_executable_path="/path/to/chromedriver",
        driver_executable_is_patched=True,
      )
    */
    bin = pkgs-undetected-chromedriver;
  };

  src = fetchFromGitHub {
    /*
    owner = "ultrafunkamsterdam";
    repo = "undetected-chromedriver";
    rev = "783b8393157b578e19e85b04d300fe06efeef653";
    hash = "sha256-vQ66TAImX0GZCSIaphEfE9O/wMNflGuGB54+29FiUJE=";
    */
    # setup.py: import version
    # https://github.com/ultrafunkamsterdam/undetected-chromedriver/pull/1686
    # add parameter driver_executable_is_patched
    # https://github.com/ultrafunkamsterdam/undetected-chromedriver/pull/1687
    owner = "ultrafunkamsterdam";
    repo = "undetected-chromedriver";
    rev = "52c80c160b747b067d14a73908ca5c0e9d3eb15a";
    hash = "sha256-42ETV3VFI4E3vNeVxovGxTr5KPFVyFlrhA7wmVVHM94=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    requests
    certifi
    websockets
    selenium
  ];

  pythonImportsCheck = [ "undetected_chromedriver" ];

  meta = with lib; {
    description = "Custom Selenium Chromedriver | Zero-Config | Passes ALL bot mitigation systems (like Distil / Imperva/ Datadadome / CloudFlare IUAM";
    homepage = "https://github.com/ultrafunkamsterdam/undetected-chromedriver";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}

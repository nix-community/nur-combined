{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, selenium
, tor-browser
, geckodriver
}:

buildPythonPackage rec {
  pname = "tbselenium";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "webfp";
    repo = "tor-browser-selenium";
    #rev = "v${version}";
    # https://github.com/webfp/tor-browser-selenium/pull/210
    rev = "b4a3397cbbf0b3ae41477b4e76d7742cbcb40128";
    hash = "sha256-Wx8c0R5vil3LVOA8deAB6tWJqz7XfWCWekfvfP+mDwM=";
  };

  # set default paths
  postPatch = ''
    substituteInPlace tbselenium/tbdriver.py \
      --replace \
        'GECKO_DRIVER_EXE_PATH = shutil.which("geckodriver")' \
        'GECKO_DRIVER_EXE_PATH = "${geckodriver}/bin/geckodriver"' \
      --replace \
        'DEFAULT_TBB_BROWSER_DIR = ""' \
        'DEFAULT_TBB_BROWSER_DIR = "${tor-browser}/share/tor-browser"' \
  '';

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    selenium
  ];

  pythonImportsCheck = [ "tbselenium" ];

  meta = with lib; {
    description = "Tor Browser automation with Selenium";
    homepage = "https://github.com/webfp/tor-browser-selenium";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

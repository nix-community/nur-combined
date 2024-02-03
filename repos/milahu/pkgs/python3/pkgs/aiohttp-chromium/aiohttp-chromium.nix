{ lib
, python3
, fetchFromGitHub
, setuptools
, wheel
, selenium-driverless
}:

python3.pkgs.buildPythonPackage rec {
  pname = "aiohttp-chromium";
  version = "0.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "aiohttp_chromium";
    rev = "61fe3150ed032ef8aa99b23dddbedaa1929c229c";
    hash = "sha256-+PvegLvsS+m+f7y26pWOQnHoBopAU+fIaVOCvNN98KA=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    selenium-driverless
  ];

  pythonImportsCheck = [ "aiohttp_chromium" ];

  meta = with lib; {
    description = "Aiohttp-like interface to chromium. based on selenium_driverless to bypass cloudflare";
    homepage = "https://github.com/milahu/aiohttp_chromium";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

{ lib
, python3
, fetchFromGitHub
, setuptools
, wheel
, selenium-driverless
}:

python3.pkgs.buildPythonPackage rec {
  pname = "aiohttp-chromium";
  version = "0.0.2";
  pyproject = true;

  src =
  #if true then /home/user/src/milahu/aiohttp_chromium else
  fetchFromGitHub {
    owner = "milahu";
    repo = "aiohttp_chromium";
    rev = version;
    hash = "sha256-fUtgFvJpxKF+d+NlJ/fb34aZoIeB/PIwk7RE37Rpykw=";
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

{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "botasaurus";
  # https://pypi.org/project/botasaurus/
  version = "3.2.3"; # 2024-01-12
  pyproject = true;

  src = fetchFromGitHub {
    owner = "omkarcloud";
    repo = "botasaurus";
    rev = "34ad082fb7f2455b330f05207f0535c91fa57475";
    hash = "sha256-Q2hAO8vye08W71SXW0hPqNmm99ahyhkw3N8JETod9wI=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  # https://github.com/omkarcloud/botasaurus/blob/master/setup.py
  propagatedBuildInputs = with python3.pkgs; [
    psutil
    requests
    javascript
    joblib
    beautifulsoup4
#    chromedriver-autoinstaller
    cloudscraper
    selenium
    botasaurus-proxy-authentication
    packaging
  ];

  pythonImportsCheck = [ "botasaurus" ];

  meta = with lib; {
    description = "The All in One Web Scraping Framework";
    homepage = "https://github.com/omkarcloud/botasaurus";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "botasaurus";
  };
}

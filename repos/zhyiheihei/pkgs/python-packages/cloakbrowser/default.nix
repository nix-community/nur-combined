{
  lib,
  python3Packages,
  sources,
}:
python3Packages.buildPythonPackage rec {
  pname = "cloakbrowser";
  inherit (sources.cloakbrowser) version src;

  pyproject = true;

  propagatedBuildInputs = with python3Packages; [
    cryptography
    httpx
    playwright
  ];

  pythonImportsCheck = [ "cloakbrowser" ];

  meta = {
    description = "Stealth-wrapped Playwright browser for anti-bot scraping";
    homepage = "https://github.com/CloakHQ/CloakBrowser";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
  };
}

{
  lib,
  sources,
  buildPythonPackage,
  cryptography,
  httpx,
  playwright,
}:
buildPythonPackage rec {
  pname = "cloakbrowser";
  inherit (sources.cloakbrowser) version src;

  pyproject = true;

  propagatedBuildInputs = [
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

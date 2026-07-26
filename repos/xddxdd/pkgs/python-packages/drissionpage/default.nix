{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  requests,
  lxml,
  cssselect,
  websocket-client,
  click,
  tldextract,
  psutil,
  setuptools,
  drissionget,
  drissionrecord,
}:
buildPythonPackage rec {
  inherit (sources.drissionpage) pname version;
  pyproject = true;

  inherit (sources.drissionpage) src;

  build-system = [ setuptools ];
  dependencies = [
    requests
    lxml
    cssselect
    drissionget
    websocket-client
    click
    tldextract
    psutil
    drissionrecord
  ];

  pythonImportsCheck = [
    "DrissionPage"
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python based web automation tool";
    homepage = "https://github.com/g1879/DrissionPage";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
}

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
  drission-get,
  drission-record,
}:
buildPythonPackage rec {
  inherit (sources.drission-page) pname version;
  pyproject = true;

  inherit (sources.drission-page) src;

  build-system = [ setuptools ];
  dependencies = [
    requests
    lxml
    cssselect
    drission-get
    websocket-client
    click
    tldextract
    psutil
    drission-record
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

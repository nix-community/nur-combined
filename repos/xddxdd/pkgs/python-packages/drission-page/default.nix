{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  requests,
  lxml,
  cssselect,
  download-kit,
  websocket-client,
  click,
  tldextract,
  psutil,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.drission-page) pname version src;

  build-system = [ setuptools ];
  dependencies = [
    requests
    lxml
    cssselect
    download-kit
    websocket-client
    click
    tldextract
    psutil
  ];

  pythonImportsCheck = [
    "DrissionPage"
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python based web automation tool. Powerful and elegant";
    homepage = "https://github.com/g1879/DrissionPage";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
}

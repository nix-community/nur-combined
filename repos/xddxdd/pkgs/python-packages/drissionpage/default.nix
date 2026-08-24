{
  fetchurl,
  lib,
  buildPythonPackage,
  # Dependencies
  nix-update-script,
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
buildPythonPackage (finalAttrs: {
  pname = "drissionpage";
  version = "4.1.1.4";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/d/drissionpage/drissionpage-${finalAttrs.version}.tar.gz";
    hash = "sha256-TGJEhcvFduFHftt3zZKjGEcE99bQ/QGSjJRKXma6Rxk=";
  };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python based web automation tool";
    homepage = "https://github.com/g1879/DrissionPage";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
})

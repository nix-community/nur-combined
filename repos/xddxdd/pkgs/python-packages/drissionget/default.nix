{
  fetchurl,
  lib,
  buildPythonPackage,
  # Dependencies
  nix-update-script,
  requests,
  drissionrecord,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "drissionget";
  version = "1.2.1";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/d/drissionget/drissionget-${finalAttrs.version}.tar.gz";
    hash = "sha256-oFUZvqWcx6WI8aWp7mhEKC5Zlj6sISuqQG2hwgvKmQg=";
  };
  build-system = [ setuptools ];
  dependencies = [
    requests
    drissionrecord
  ];

  pythonImportsCheck = [ "DrissionGet" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Multi-threaded file download toolkit";
    homepage = "https://DrissionPage.cn/DrissionGet";
    license = with lib.licenses; [ bsd3 ];
  };
})

{
  fetchurl,
  lib,
  buildPythonPackage,
  # Dependencies
  nix-update-script,
  requests,
  datarecorder,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "downloadkit";
  version = "2.0.7";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/D/DownloadKit/DownloadKit-${finalAttrs.version}.tar.gz";
    hash = "sha256-YB5CPR1NC9PpM1JNBskT50RXfUVZkOwgr8P7H3muqac=";
  };
  build-system = [ setuptools ];
  dependencies = [
    requests
    datarecorder
  ];

  pythonImportsCheck = [
    "DownloadKit"
  ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Simple to use multi-threaded download toolkit";
    homepage = "https://github.com/g1879/DownloadKit";
    license = with lib.licenses; [ bsd3 ];
  };
})

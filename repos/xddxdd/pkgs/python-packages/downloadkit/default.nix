{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  requests,
  datarecorder,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.downloadkit) pname version;
  pyproject = true;

  inherit (sources.downloadkit) src;

  build-system = [ setuptools ];
  dependencies = [
    requests
    datarecorder
  ];

  pythonImportsCheck = [
    "DownloadKit"
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Simple to use multi-threaded download toolkit";
    homepage = "https://github.com/g1879/DownloadKit";
    license = with lib.licenses; [ bsd3 ];
  };
}

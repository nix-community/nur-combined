{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  requests,
  data-recorder,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.download-kit) pname version src;

  build-system = [ setuptools ];
  dependencies = [
    requests
    data-recorder
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

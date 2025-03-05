{
  lib,
  sources,
  buildPythonPackage,
  python3Packages,
  # Dependencies
  requests,
  data-recorder,
}:
buildPythonPackage rec {
  inherit (sources.download-kit) pname version src;

  build-system = with python3Packages; [ setuptools ];
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

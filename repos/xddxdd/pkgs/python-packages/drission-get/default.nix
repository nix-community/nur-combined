{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  requests,
  drission-record,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.drission-get) pname version;
  pyproject = true;

  inherit (sources.drission-get) src;

  build-system = [ setuptools ];
  dependencies = [
    requests
    drission-record
  ];

  pythonImportsCheck = [ "DrissionGet" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Multi-threaded file download toolkit";
    homepage = "https://DrissionPage.cn/DrissionGet";
    license = with lib.licenses; [ bsd3 ];
  };
}

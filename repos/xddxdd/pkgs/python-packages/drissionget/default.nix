{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  requests,
  drissionrecord,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.drissionget) pname version;
  pyproject = true;

  inherit (sources.drissionget) src;

  build-system = [ setuptools ];
  dependencies = [
    requests
    drissionrecord
  ];

  pythonImportsCheck = [ "DrissionGet" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Multi-threaded file download toolkit";
    homepage = "https://DrissionPage.cn/DrissionGet";
    license = with lib.licenses; [ bsd3 ];
  };
}

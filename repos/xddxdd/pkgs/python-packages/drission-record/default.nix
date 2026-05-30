{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  openpyxl,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.drission-record) pname version;
  pyproject = true;

  inherit (sources.drission-record) src;

  build-system = [ setuptools ];
  dependencies = [ openpyxl ];

  pythonImportsCheck = [ "DrissionRecord" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python data recording toolkit";
    homepage = "https://gitcode.com/g1879/DrissionRecord";
    license = with lib.licenses; [ mit ];
  };
}

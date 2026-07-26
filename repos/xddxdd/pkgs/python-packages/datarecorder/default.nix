{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  openpyxl,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.datarecorder) pname version;
  pyproject = true;

  inherit (sources.datarecorder) src;

  build-system = [ setuptools ];
  dependencies = [
    openpyxl
  ];

  pythonImportsCheck = [
    "DataRecorder"
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python-based toolkit to record data into files";
    homepage = "https://github.com/g1879/DataRecorder";
    license = with lib.licenses; [ mit ];
  };
}

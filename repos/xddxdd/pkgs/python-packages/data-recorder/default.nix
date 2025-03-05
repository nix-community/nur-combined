{
  lib,
  sources,
  buildPythonPackage,
  python3Packages,
  # Dependencies
  openpyxl,
}:
buildPythonPackage rec {
  inherit (sources.data-recorder) pname version src;

  build-system = with python3Packages; [ setuptools ];
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

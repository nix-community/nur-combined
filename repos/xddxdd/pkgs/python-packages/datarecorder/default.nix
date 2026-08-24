{
  fetchurl,
  lib,
  buildPythonPackage,
  # Dependencies
  nix-update-script,
  openpyxl,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "datarecorder";
  version = "3.6.2";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/D/DataRecorder/DataRecorder-${finalAttrs.version}.tar.gz";
    hash = "sha256-jJAkc2aSr2i5R/2IRYnmhcTye8KdAxuBFkRXsJxg4eU=";
  };
  build-system = [ setuptools ];
  dependencies = [
    openpyxl
  ];

  pythonImportsCheck = [
    "DataRecorder"
  ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python-based toolkit to record data into files";
    homepage = "https://github.com/g1879/DataRecorder";
    license = with lib.licenses; [ mit ];
  };
})

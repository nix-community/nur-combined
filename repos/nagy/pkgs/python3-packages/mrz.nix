{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "mrz";
  version = "0.6.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VLs7NwzMNxt/uGwFrdiHQ0bnqGaY2IIsSITLYZBP+O4=";
  };

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "mrz"
  ];

  meta = {
    description = "Machine readable zone generator and checker for passports, visas, id cards and other travel documents";
    homepage = "https://pypi.org/project/mrz";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "mrz";
  };
}

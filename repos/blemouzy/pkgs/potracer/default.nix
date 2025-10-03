{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  setuptools,
  numpy,
}:

buildPythonPackage rec {
  pname = "potracer";
  version = "0.0.4";
  pyproject = true;

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MsvbmERGBmvPvotgAUKlS5D6baJ0tpIZRzIF1uTAlxM=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [ numpy ];

  # no upstream tests
  doCheck = false;

  pythonImportsCheck = [ "potrace" ];

  meta = {
    description = "Pure Python Port of Potrace";
    homepage = "https://github.com/tatarize/potrace";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ jfvillablanca ];
  };
}

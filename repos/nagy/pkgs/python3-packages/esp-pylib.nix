{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  wheel,
  rich,
  rich-click,
  click,
  websockets,
  pyserial,
}:

buildPythonPackage rec {
  pname = "esp-pylib";
  version = "1.1.2";
  pyproject = true;

  src = fetchPypi {
    pname = "esp_pylib";
    inherit version;
    hash = "sha256-sl8kjrnpIm0JCzOCyL5dGIQ1kHjD6UwaMExkd6NKESM=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    rich
    rich-click
    click
    websockets
    pyserial
  ];

  pythonImportsCheck = [ "esp_pylib" ];

  meta = {
    description = "Python library for logging, utils and constants for Espressif Systems' Python projects";
    homepage = "https://pypi.org/project/esp-pylib/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagy ];
  };
}

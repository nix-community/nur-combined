{
  lib,
  fetchPypi,
  buildPythonPackage,

  # build-system
  setuptools,
  wheel,

  # dependencies
  rich,

  # optional dependencies
  rich-click,
  click,
  websockets,
  pyserial,
}:

buildPythonPackage rec {
  pname = "esp-pylib";
  version = "1.1.5";
  pyproject = true;

  src = fetchPypi {
    pname = "esp_pylib";
    inherit version;
    hash = "sha256-MAa8lWL5UmlX4J7oSIF0Y8Iv4QzPjqaLYVU5BsvAieA=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    rich
  ];

  passthru.optional-dependencies = {
    ide = [ websockets ];
    serial = [ pyserial ];
    cli = [ rich-click click ];
  };

  pythonImportsCheck = [ "esp_pylib" ];

  meta = {
    description = "Python library for logging, utils and constants for Espressif Systems' Python projects";
    homepage = "https://pypi.org/project/esp-pylib/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagy ];
  };
}

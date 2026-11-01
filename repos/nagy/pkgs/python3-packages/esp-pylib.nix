{
  lib,
  pkgs,
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
  version = "1.2.0";
  pyproject = true;

  src = fetchPypi {
    pname = "esp_pylib";
    inherit version;
    hash = "sha256-UfDESg96kv3e2cq1S96SRBsitGT31oTtF5r7VwAL7XA=";
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
    cli = [
      rich-click
      click
    ];
  };

  pythonImportsCheck = [ "esp_pylib" ];

  passthru.updateScript = pkgs.nix-update-script { };

  meta = {
    description = "Python library for logging, utils and constants for Espressif Systems' Python projects";
    homepage = "https://pypi.org/project/esp-pylib/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagy ];
  };
}

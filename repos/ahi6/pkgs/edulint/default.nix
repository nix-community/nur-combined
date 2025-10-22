{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  pylint,
  dataclasses-json,
  tomli,
  requests,
  platformdirs,
  loguru,
  flake8,
  flake8_json,
  callPackage,
  pkgs,
}:
buildPythonPackage rec {
  pname = "edulint";
  version = "4.2.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HghX6OBG+r2rJQUspnJHWZicnjZCgDk8MxoWaxAABjA=";
  };

  # do not run tests
  doCheck = false;

  # specific to buildPythonPackage, see its reference
  pyproject = true;
  build-system = [
    setuptools
  ];
  dependencies = [
    flake8
    flake8_json
    pylint
    dataclasses-json
    tomli
    requests
    platformdirs
    loguru
  ];

  pythonRelaxDeps = true;

  meta = {
    description = "Python linter aimed at helping novice programmers improve their coding style";
    homepage = "https://github.com/GiraffeReversed/edulint";
    license = lib.licenses.gpl3Only;
    mainProgram = "edulint";
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
}:
buildPythonPackage rec {
  pname = "flake8_json";
  version = "24.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QCk3Y8MO/Pac9ELqt+gSTCfzbpfn3V0J7axtVlsgJd4=";
  };

  # do not run tests
  doCheck = false;

  # specific to buildPythonPackage, see its reference
  pyproject = true;
  build-system = [
    setuptools
  ];

  meta = {
    description = "JSON Formatting Reporter plugin for Flake8";
    homepage = "https://pypi.org/project/flake8-json";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
  };
}

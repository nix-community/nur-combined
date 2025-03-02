{
  buildPythonPackage,
  autobean-refactor,
  pdm-pep517,
  source,
  lib,
}:
buildPythonPackage {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  format = "pyproject";

  propagatedBuildInputs = [
    pdm-pep517
    autobean-refactor
  ];
}

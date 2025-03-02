{
  buildPythonPackage,
  lark,
  pdm-pep517,
  source,
  typing-extensions,
  lib,
}:
buildPythonPackage {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  format = "pyproject";

  propagatedBuildInputs = [
    lark
    pdm-pep517
    typing-extensions
  ];
}

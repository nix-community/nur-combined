{
  lib,
  buildPythonPackage,
  setuptools,
  tree-sitter,
  source,
}:

buildPythonPackage {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  pyproject = true;

  buildInputs = [ tree-sitter ];

  build-system = [ setuptools ];
}

{
  buildPythonPackage,
  setuptools,
  tree-sitter,
  source,
}:

buildPythonPackage {
  inherit (source) pname src version;
  pyproject = true;

  buildInputs = [ tree-sitter ];

  build-system = [ setuptools ];
}

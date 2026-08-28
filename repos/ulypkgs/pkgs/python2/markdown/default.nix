{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  nose,
  pyyaml,
  pythonOlder,
  importlib-metadata,
}:

buildPythonPackage (finalAttrs: {
  pname = "Markdown";
  version = "3.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-LlCHa83XRRfntx8+enYQIFDt7CVbOYNAPxpj58ikHno=";
  };

  propagatedBuildInputs = [
    setuptools
  ]
  ++ lib.optionals (pythonOlder "3.8") [
    importlib-metadata
  ];

  checkInputs = [
    nose
    pyyaml
  ];

  meta = {
    description = "A Python implementation of John Gruber's Markdown with Extension support";
    homepage = "https://github.com/Python-Markdown/markdown";
    license = lib.licenses.bsd3;
  };
})

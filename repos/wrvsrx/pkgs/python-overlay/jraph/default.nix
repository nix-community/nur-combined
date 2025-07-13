{
  buildPythonPackage,
  jax,
  jaxlib,
  numpy,
  setuptools,
  source,
}:

buildPythonPackage {
  inherit (source) pname version src;
  pyproject = true;
  nativeBuildInputs = [ setuptools ];
  buildInputs = [ jaxlib ];
  propagatedBuildInputs = [
    jax
    numpy
  ];
}

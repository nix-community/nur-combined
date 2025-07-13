{
  buildPythonPackage,
  jax,
  jaxlib,
  numpy,
  source,
}:

buildPythonPackage {
  inherit (source) pname version src;
  pyproject = true;
  build-system = [ "setuptools" ];
  buildInputs = [ jaxlib ];
  propagatedBuildInputs = [
    jax
    numpy
  ];
}

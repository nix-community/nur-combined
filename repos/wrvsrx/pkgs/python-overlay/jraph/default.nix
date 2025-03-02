{
  buildPythonPackage,
  jax,
  jaxlib,
  numpy,
  source,
}:

buildPythonPackage {
  inherit (source) pname version src;
  buildInputs = [ jaxlib ];
  propagatedBuildInputs = [
    jax
    numpy
  ];
}

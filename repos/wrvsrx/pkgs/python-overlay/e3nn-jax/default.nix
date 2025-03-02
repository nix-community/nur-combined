{
  buildPythonPackage,
  jax,
  jaxlib,
  numpy,
  sympy,
  attrs,
  setuptools,
  setuptools-scm,
  source,
}:

buildPythonPackage {
  inherit (source) pname version src;
  pyproject = true;
  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];
  buildInputs = [ jaxlib ];
  propagatedBuildInputs = [
    jax
    sympy
    numpy
    attrs
  ];
}

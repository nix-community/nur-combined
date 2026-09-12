{
  buildPythonPackage,
  jax,
  jaxlib,
  numpy,
  sympy,
  attrs,
  setuptools,
  setuptools-scm,
  fetchurl,
}:

buildPythonPackage rec {
  pname = "e3nn-jax";
  version = "0.20.7";

  src = fetchurl {
    url = "https://pypi.org/packages/source/e/e3nn_jax/e3nn_jax-${version}.tar.gz";
    hash = "sha256-d2TtuZ0ZRl5XSiOFfl+XQgtNcg8GuovBigH58rgwHRw=";
  };
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

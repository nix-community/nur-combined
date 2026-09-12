{
  buildPythonPackage,
  jax,
  jaxlib,
  numpy,
  absl-py,
  flax,
  jraph,
  ml-collections,
  e3nn-jax,
  dm-haiku,
  optax,
  frozendict,
  pymatgen,
  einops,
  fetchurl,
}:

buildPythonPackage rec {
  pname = "jax-md";
  version = "0.2.8";

  src = fetchurl {
    url = "https://pypi.org/packages/source/j/jax-md/jax-md-${version}.tar.gz";
    hash = "sha256-rXTkQ8jomTPjiw4mVLUvf1rqu9gaCTTHZfCUF+qi6Vs=";
  };
  pyproject = true;
  build-system = [ "setuptools" ];
  buildInputs = [ jaxlib ];
  propagatedBuildInputs = [
    absl-py
    numpy
    jax
    flax
    jraph
    einops
    ml-collections
    e3nn-jax
    dm-haiku
    optax
    frozendict
    pymatgen
  ];
}

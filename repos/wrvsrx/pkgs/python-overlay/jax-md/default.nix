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
  source,
}:

buildPythonPackage {
  inherit (source) pname version src;
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

{
  buildPythonPackage,
  jax,
  jaxlib,
  numpy,
  setuptools,
  fetchurl,
}:

buildPythonPackage rec {
  pname = "jraph";
  version = "0.0.6.dev0";

  src = fetchurl {
    url = "https://pypi.org/packages/source/j/jraph/jraph-${version}.tar.gz";
    hash = "sha256-w6w6CyJLNE6202fovDEtlepBv4JdAeoxuA3YwiwN2Lg=";
  };
  pyproject = true;
  nativeBuildInputs = [ setuptools ];
  buildInputs = [ jaxlib ];
  propagatedBuildInputs = [
    jax
    numpy
  ];
}

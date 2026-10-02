{ lib, buildPythonPackage, fetchPypi, setuptools, healpy, matplotlib }:

buildPythonPackage rec {
  pname = "mhealpy";
  version = "0.3.7";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lkkggvBcNgKRzM8383LlZ9jzqfprDMAdX7uXLVwqah8=";
  };

  build-system = [ setuptools ];
  dependencies = [ healpy matplotlib ];
  pythonImportsCheck = [ "mhealpy" ];

  meta = {
    description = "Multi resolution HEALPix maps in Python";
    homepage = "https://github.com/ntessore/mhealpy";
    license = lib.licenses.mit;
  };
}

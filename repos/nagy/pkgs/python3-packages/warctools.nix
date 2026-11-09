{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "warctools";
  version = "5.0.1";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-diHa4nNnPfnxsuosspLn+mbT7vprMCJp5FdAej++IY4=";
  };

  build-system = [ setuptools ];

  doCheck = false;

  meta = {
    homepage = "https://github.com/internetarchive/warctools";
    description = "Command line tools and libraries for handling and manipulating WARC files (and HTTP contents)";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
})

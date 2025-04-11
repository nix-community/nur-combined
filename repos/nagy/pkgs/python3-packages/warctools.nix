{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "warctools";
  version = "4.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zgxuJ024rIgQ98l7OUPo6N6tvD9cmC23fN2q4tKuYXA=";
  };

  propagatedBuildInputs = [ setuptools ];

  doCheck = false;

  meta = {
    homepage = "https://github.com/internetarchive/warctools";
    description = "Command line tools and libraries for handling and manipulating WARC files (and HTTP contents)";
    license = lib.licenses.mit;
  };
}

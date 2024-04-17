{ pkgs
, lib
, python3Packages
, buildPythonPackage ? python3Packages.buildPythonPackage
, fetchPypi ? python3Packages.fetchPypi
,
}:
buildPythonPackage rec {
  pname = "pysubs2";
  version = "1.6.1";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-AmFhHnFzX/d2OXLFGcclk8gGPvy5A5xUr2XzG4HOwRY=";
  };
  buildInputs = with python3Packages; [ setuptools ];
  meta = with lib; {
    description = "A Python library for editing subtitle files";
    homepage = "https://github.com/tkarabela/pysubs2";
    license = licenses.mit;
    maintainers = [ ];
  };
}

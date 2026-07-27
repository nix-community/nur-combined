{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  hatch-vcs,
  requests,
}:

buildPythonPackage rec {
  pname = "pyconify";
  version = "0.2.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jdU3V9n77UFxFDRGCTKytdvCXacgzZ+aRK8Bh7LfwH0=";
  };

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [ requests ];

  doCheck = false;

  meta = with lib; {
    description = "Python wrapper for the Iconify API";
    homepage = "https://github.com/pyapp-kit/pyconify";
    license = licenses.bsd3;
  };
}

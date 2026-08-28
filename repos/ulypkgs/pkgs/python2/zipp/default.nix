{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
  pytest,
  pytest-flake8,
  more-itertools,
}:

buildPythonPackage (finalAttrs: {
  pname = "zipp";
  version = "1.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-04++Abv3o1k6Mrw1qcRFPDK8QrmMN3+b/36fjaFXeGw=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [ more-itertools ];

  checkInputs = [
    pytest
    pytest-flake8
  ];

  checkPhase = ''
    pytest
  '';

  # Prevent infinite recursion with pytest
  doCheck = false;

  meta = with lib; {
    description = "Pathlib-compatible object wrapper for zip files";
    homepage = "https://github.com/jaraco/zipp";
    license = licenses.mit;
  };
})

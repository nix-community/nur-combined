{ lib, fetchPypi, buildPythonPackage, setuptools_scm, numba, scipy, openssl
, installShellFiles, pillow }:

buildPythonPackage rec {
  pname = "PyMatting";
  version = "1.1.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-8rFIF0VhuejHZ3fU5L5+t5jII98N6lDSID9bm4FFOps=";
  };

  pythonImportsCheck = [ "pymatting" ];

  nativeBuildInputs = [ setuptools_scm installShellFiles ];

  propagatedBuildInputs = [ pillow numba scipy openssl ];

  doCheck = false;

  meta = with lib; {
    description = "Python library for alpha matting";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

{ lib, fetchPypi, buildPythonPackage, numba, scipy, openssl, installShellFiles
, pillow }:

buildPythonPackage rec {
  pname = "PyMatting";
  version = "1.1.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-pzUI7wh0mWgx39KE47xjFRoJSE14n9EO3AP0mzFTKsw=";
  };

  pythonImportsCheck = [ "pymatting" ];

  nativeBuildInputs = [ installShellFiles ];

  propagatedBuildInputs = [ pillow numba scipy openssl ];

  doCheck = false;

  meta = with lib; {
    description = "Python library for alpha matting";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

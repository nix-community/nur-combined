{ lib, stdenv, fetchPypi, buildPythonPackage, pytest, cython, autoconf, python
}:

buildPythonPackage rec {
  pname = "DTLSSocket";
  version = "0.1.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06476x701k5p04vsr5fn6mb2vv9bi56cxbwcvb6z2yfjvlif741h";
  };

  nativeBuildInputs = [ cython autoconf ];

  # Pypi doesn't contain tests.
  doCheck = false;

  meta = with lib; {
    description =
      "DTLSSocket is a cython wrapper for tinydtls with a Socket like interface";
    homepage = "https://git.fslab.de/jkonra2m/tinydtls-cython";
    license = licenses.epl10;
  };
}

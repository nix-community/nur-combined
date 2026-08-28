{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  python,
  stdenv,
}:

buildPythonPackage (finalAttrs: {
  pname = "futures";
  version = "3.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-fgM692peNfWOVtp6keaHcG+vTnvfssvD8symubzal5Q=";
  };

  # This module is for backporting functionality to Python 2.x, it's builtin in py3k
  disabled = isPy3k;

  checkPhase = ''
    ${python.interpreter} test_futures.py
  '';

  doCheck = !stdenv.isDarwin;

  meta = with lib; {
    description = "Backport of the concurrent.futures package from Python 3.2";
    homepage = "https://github.com/agronholm/pythonfutures";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
})

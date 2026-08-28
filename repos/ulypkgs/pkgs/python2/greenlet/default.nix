{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "greenlet";
  version = "1.1.2";
  disabled = isPyPy; # builtin for pypy

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-4w9epK4jRuYs7d6HlKVoWKZ7h43Xn333agdn41axdEo=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m unittest discover -v greenlet.tests
    runHook postCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/python-greenlet/greenlet";
    description = "Module for lightweight in-process concurrent programming";
    license = with licenses; [
      psfl # src/greenlet/slp_platformselect.h & files in src/greenlet/platform/ directory
      mit
    ];
  };
})

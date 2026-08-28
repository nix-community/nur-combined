{
  lib,
  buildPythonPackage,
  fetchPypi,
  markdown,
  isPy3k,
  TurboCheetah,
}:

buildPythonPackage (finalAttrs: {
  pname = "cheetah";
  version = "2.4.4";

  disabled = isPy3k;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-vjCCKfDB5eWvTyfX7gbZC7GeavMFl5Tl/VNqbymptVA=";
  };

  propagatedBuildInputs = [ markdown ];

  doCheck = false; # Circular dependency

  checkInputs = [
    TurboCheetah
  ];

  meta = {
    homepage = "http://www.cheetahtemplate.org/";
    description = "A template engine and code generation tool";
    license = lib.licenses.mit;
  };
})

{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "idna";
  version = "2.10";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-sweHL4VbGGMs4MIcXkW+eMDqeuTBXIKMIHiLJpIes/Y=";
  };

  checkInputs = [ pytestCheckHook ];

  meta = {
    homepage = "https://github.com/kjd/idna/";
    description = "Internationalized Domain Names in Applications (IDNA)";
    license = lib.licenses.bsd3;
  };
})

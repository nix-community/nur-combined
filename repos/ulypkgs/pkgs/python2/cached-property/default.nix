{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  freezegun,
}:

buildPythonPackage (finalAttrs: {
  pname = "cached-property";
  version = "1.5.1";

  # conftest.py is missing in PyPI tarball
  src = fetchFromGitHub {
    owner = "pydanny";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-Bpcp9GhFpvZUAqIBLVIynNbmyQDOO2sTjaDPGCu/AHY=";
  };

  checkInputs = [ freezegun ];
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    "test_threads_ttl_expiry"
  ];
  doCheck = false; # not sure why the `disabledTests` attr does not work

  meta = {
    description = "A decorator for caching properties in classes";
    homepage = "https://github.com/pydanny/cached-property";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ ericsagnes ];
  };
})

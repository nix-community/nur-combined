{
  lib,
  python3Packages,
  replaceVars,
  locale,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "click";
  version = "6.7";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-8VUW30eNWlYYD7+A5o8gYBDm0WD8OfpQi2XgNf11Ews=";
  };

  patches = lib.optionals (lib.versionAtLeast finalAttrs.version "6.7") [
    (replaceVars ./fix-paths.patch {
      locale = "${locale}/bin/locale";
    })
  ];

  build-system = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    # https://github.com/pallets/click/issues/823
    "test_legacy_callbacks"
  ];

  meta = {
    homepage = "http://click.pocoo.org/";
    description = "Create beautiful command line interfaces in Python";
    license = lib.licenses.bsd3;
  };
})

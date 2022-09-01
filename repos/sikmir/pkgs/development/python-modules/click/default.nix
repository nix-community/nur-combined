{ lib, python3Packages, substituteAll, locale }:

python3Packages.buildPythonPackage rec {
  pname = "click";
  version = "6.7";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-8VUW30eNWlYYD7+A5o8gYBDm0WD8OfpQi2XgNf11Ews=";
  };

  patches = lib.optional (lib.versionAtLeast version "6.7") (
    substituteAll {
      src = ./fix-paths.patch;
      locale = "${locale}/bin/locale";
    }
  );

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    # https://github.com/pallets/click/issues/823
    "test_legacy_callbacks"
  ];

  meta = with lib; {
    homepage = "http://click.pocoo.org/";
    description = "Create beautiful command line interfaces in Python";
    license = licenses.bsd3;
  };
}

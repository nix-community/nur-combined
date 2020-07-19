{ lib, python3Packages, substituteAll, locale }:
let
  pname = "click";
  version = "6.7";
in
python3Packages.buildPythonPackage {
  inherit pname version;

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "02qkfpykbq35id8glfgwc38yc430427yd05z1wc5cnld8zgicmgi";
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

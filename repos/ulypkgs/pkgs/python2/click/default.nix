{
  lib,
  buildPythonPackage,
  fetchPypi,
  locale,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "click";
  version = "7.1.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-0rUlXHxjSbwb0eWeCM0SrLvWPOZJ8liHVXg6qU37axo=";
  };

  postPatch = ''
    substituteInPlace src/click/_unicodefun.py \
      --replace "'locale'" "'${locale}/bin/locale'"
  '';

  checkInputs = [ pytestCheckHook ];

  meta = with lib; {
    homepage = "https://click.palletsprojects.com/";
    description = "Create beautiful command line interfaces in Python";
    longDescription = ''
      A Python package for creating beautiful command line interfaces in a
      composable way, with as little code as necessary.
    '';
    license = licenses.bsd3;
  };
})

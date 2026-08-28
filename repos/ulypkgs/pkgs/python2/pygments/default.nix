{
  lib,
  buildPythonPackage,
  fetchPypi,
  docutils,
}:

buildPythonPackage (finalAttrs: {
  pname = "Pygments";
  version = "2.5.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-mMiqWp93j80QJqFzYd2vczDRt8Yq6Xw7sK5z4Lm2sP4=";
  };

  propagatedBuildInputs = [ docutils ];

  # Circular dependency with sphinx
  doCheck = false;

  meta = {
    homepage = "https://pygments.org/";
    description = "A generic syntax highlighter";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ];
  };
})

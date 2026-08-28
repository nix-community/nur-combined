{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "pathspec";
  version = "0.9.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-5WRJlDWiZz1Yb2shMLtblfBKO6Bvgbj4lbZRo8dqq7E=";
  };

  meta = {
    description = "Utility library for gitignore-style pattern matching of file paths";
    homepage = "https://github.com/cpburnz/python-path-specification";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ copumpkin ];
  };
})

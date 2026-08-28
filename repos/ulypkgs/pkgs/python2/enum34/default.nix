{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonAtLeast,
  python,
}:

if pythonAtLeast "3.4" then
  null
else
  buildPythonPackage (finalAttrs: {
    pname = "enum34";
    version = "1.1.10";

    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-zOanR37YFr0lQtA9U9ufDbk13QE7cPM2qVxzl5KJ8kg=";
    };

    checkPhase = ''
      ${python.interpreter} -m unittest discover
    '';

    meta = with lib; {
      homepage = "https://pypi.python.org/pypi/enum34";
      description = "Python 3.4 Enum backported to 3.3, 3.2, 3.1, 2.7, 2.6, 2.5, and 2.4";
      license = licenses.bsd0;
    };

  })

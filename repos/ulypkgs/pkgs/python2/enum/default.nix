{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  isPyPy,
}:

buildPythonPackage (finalAttrs: {
  pname = "enum";
  version = "0.4.7";
  disabled = isPy3k;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-jHzzWH7aUQCLzB7tmeosMxzNJlwjHbqpXsUljT3AMQA=";
  };

  doCheck = !isPyPy;

  meta = with lib; {
    homepage = "https://pypi.python.org/pypi/enum/";
    description = "Robust enumerated type support in Python";
    license = licenses.gpl2;
  };

})

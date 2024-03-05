{ lib
, fetchPypi
, buildPythonPackage
, setuptools
, anyio
, poetry-core
, typing-extensions
}:

buildPythonPackage rec {
  pname = "asyncer";
  version = "0.0.5";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-KXnz4Ey+3+XP63kCfc99AE/MRDCgygBmriBJDyGOwG4=";
  };

  propagatedBuildInputs = [ poetry-core anyio typing-extensions ];

  pythonImportsCheck = [ "asyncer" ];

  meta = with lib; {
    description = "Asyncer, async and await, focused on developer experience";
    homepage = "https://github.com/tiangolo/asyncer";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

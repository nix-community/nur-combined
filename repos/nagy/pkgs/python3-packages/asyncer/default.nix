{ lib
, fetchPypi
, buildPythonApplication
, setuptools
, anyio
, typing-extensions
}:

buildPythonApplication rec {
  pname = "asyncer";
  version = "0.0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-1UbIXzYm67rwa7Q5XbSXYckCphpqyAKxp0EzyrT39DM=";
  };

  propagatedBuildInputs = [ setuptools anyio typing-extensions ];

  pythonImportsCheck = [ "asyncer" ];

  meta = with lib; {
    description = "Asyncer, async and await, focused on developer experience";
    homepage = "https://github.com/tiangolo/asyncer";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

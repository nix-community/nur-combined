{ lib, fetchPypi, buildPythonApplication, setuptools, anyio, typing-extensions }:

buildPythonApplication rec {
  pname = "asyncer";
  version = "0.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-o/cGhfIM2R4kpneYHKzb3W1rgfJAS3v+lX6VUP7iZKE=";
  };

  propagatedBuildInputs = [ setuptools anyio typing-extensions ];

  pythonImportsCheck = [ "asyncer" ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/tiangolo/asyncer";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

{ lib, pathspec, fetchPypi, buildPythonApplication }:

buildPythonApplication rec {
  pname = "ssort";
  version = "0.11.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-If7Ek0h/Mt/1DTDvpbaq0YKG6YF2ALZL/mhq4GK6564=";
  };

  buildInputs = [
    pathspec
  ];

  meta = with lib; {
    description = "Tool for sorting top level statements in python files";
    homepage = "https://github.com/bwhmather/ssort/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

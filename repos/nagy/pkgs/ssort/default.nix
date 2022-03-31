{ lib, pathspec, fetchPypi, buildPythonApplication }:

buildPythonApplication rec {
  pname = "ssort";
  version = "0.11.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Q7m1+uOf25V2HMdGTLILoVWZTnEh0FLw82aZ/JkONkU=";
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

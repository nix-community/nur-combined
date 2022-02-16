{ lib, fetchPypi, buildPythonApplication }:

buildPythonApplication rec {
  pname = "ssort";
  version = "0.10.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-uM8zEgKxT6+xYqONSEnbvvaqls27y6c+nHModOuyVOg=";
  };

  meta = with lib; {
    description = "Tool for sorting top level statements in python files";
    homepage = "https://github.com/bwhmather/ssort/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

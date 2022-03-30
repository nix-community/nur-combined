{ lib, pathspec, fetchPypi, buildPythonApplication }:

buildPythonApplication rec {
  pname = "ssort";
  version = "0.11.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-dKtU2ofjapjz6Hmmp+OsE5Nz63g2JABTTiNGRd/38Dw=";
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

{
  lib,
  fetchPypi,
  buildPythonApplication,
  tabulate,
  setuptools,
}:

buildPythonApplication rec {
  pname = "jtbl";
  version = "1.6.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-feDLCOuys6Blgimo7dQgTGlEy9nj4EckqeojWmHBFaU=";
  };

  propagatedBuildInputs = [
    setuptools
    tabulate
  ];

  pythonImportsCheck = [ "jtbl" ];

  meta = {
    description = "Simple CLI tool to print JSON and JSON Lines data as a table in the terminal";
    homepage = "https://github.com/kellyjonbrazil/jtbl";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}

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
    sha256 = "sha256-feDLCOuys6Blgimo7dQgTGlEy9nj4EckqeojWmHBFaU=";
  };

  propagatedBuildInputs = [
    setuptools
    tabulate
  ];

  pythonImportsCheck = [ "jtbl" ];

  meta = with lib; {
    description = "Simple CLI tool to print JSON and JSON Lines data as a table in the terminal";
    homepage = "https://github.com/kellyjonbrazil/jtbl";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

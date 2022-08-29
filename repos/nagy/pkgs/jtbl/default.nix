{ lib, fetchPypi, buildPythonApplication, setuptools, installShellFiles, tabulate }:

buildPythonApplication rec {
  pname = "jtbl";
  version = "1.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-HpnSLrTMNa/CpmiSjP13nFJtVb4Zqbyw4CcPqlgI98c=";
  };

  propagatedBuildInputs = [ tabulate ];

  pythonImportsCheck = [ "jtbl" ];

  meta = with lib; {
    description =
      "Simple CLI tool to print JSON and JSON Lines data as a table in the terminal";
    homepage = "https://github.com/kellyjonbrazil/jtbl";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

{ stdenv, buildPythonApplication, fetchPypi }:

buildPythonApplication rec {
  pname = "ydiff";
  version = "1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0mxcl17sx1d4vaw22ammnnn3y19mm7r6ljbarcjzi519klz26bnf";
  };

  meta = with stdenv.lib; {
    description = "View colored, incremental diff in a workspace or from " +
      "stdin, with side by side and auto pager support";
    homepage = https://github.com/ymattw/ydiff;
    license = with licenses; bsd3;
    maintainers = with maintainers; [ bb010g ];
  };
}

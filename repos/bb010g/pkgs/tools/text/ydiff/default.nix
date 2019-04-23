{ stdenv, buildPythonApplication, fetchPypi }:

buildPythonApplication rec {
  pname = "ydiff";
  version = "1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "ce2e233e9d2994f825cb6a496af2a935053facb5b52a21b8daa485ae4fa0ac57";
  };

  meta = with stdenv.lib; {
    description = "View colored, incremental diff in a workspace or from " +
      "stdin, with side by side and auto pager support";
    homepage = https://github.com/ymattw/ydiff;
    license = with licenses; bsd3;
    maintainers = with maintainers; [ bb010g ];
  };
}

{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
}:

buildPythonPackage rec {
  pname = "rapidfuzz";
  version = "0.9.1";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "15058e1b291dd96c63969bf17843da55fd7caa75e195422db2365287e955e4dd";
  };

  meta = with lib; {
    description = "Rapid fuzzy string matching";
    homepage = "https://github.com/maxbachmann/rapidfuzz";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}

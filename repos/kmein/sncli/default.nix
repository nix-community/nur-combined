{ buildPythonPackage, buildPythonApplication, fetchPypi, requests, urwid }:
let
  Simperium3 = buildPythonPackage rec {
    pname = "Simperium3";
    version = "0.1.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "1j1w4dji39v44l96qq9kbrxpcjkjmika8065gwy8bf847f9fa76p";
    };
    propagatedBuildInputs = [ requests ];
  };
in buildPythonApplication rec {
  pname = "sncli";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "18s5a6s2z7k14cbiyfdf98kw92r2hf1xwaavx67dxhadxm18xr4v";
  };

  propagatedBuildInputs = [ requests urwid Simperium3 ];
}

{ buildPythonApplication, fetchPypi, requests }:
let
in buildPythonApplication rec {
  pname = "instaloader";
  version = "4.2.4";
  src = fetchPypi {
    inherit pname version;
    sha256 = "02zqb02idk2pzks7dv42vigcmmpjpfhfdyjp911yr0ix7dy3q0b9";
  };
  propagatedBuildInputs = [ requests ];
  doCheck = false;
}

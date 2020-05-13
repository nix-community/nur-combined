{ buildPythonPackage, buildPythonApplication, fetchPypi, pytestrunner, six, beautifulsoup4, requests, dbus-python }:
let
  lyricwikia = buildPythonPackage rec {
    pname = "lyricwikia";
    version = "0.1.9";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0sa5wkbgp5bpgkl8hgn7byyz9zj0786647ikf2l0k8m4fimq623y";
    };
    buildInputs = [ pytestrunner ];
    propagatedBuildInputs = [ six beautifulsoup4 requests ];
    doCheck = false;
  };
in buildPythonApplication rec {
  pname = "spotify-cli-linux";
  version = "1.4.2";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1gxich3v2i4lmh60abbw3mw15399afvvqflv8g6plvvbmvxmbgp0";
  };
  propagatedBuildInputs = [ lyricwikia dbus-python ];
  doCheck = false;
}

{ lib
, buildPythonPackage
, fetchPypi
, webrtcvad
}:

buildPythonPackage rec {
  pname = "rhasspy-silence";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-5o/rGzPi+Lw275fnsxMxDA/ir25gY2S7S1XPu+gdZd4=";
  };

  propagatedBuildInputs = [
    webrtcvad
  ];

  meta = with lib; {
    description = "Silence detection in audio stream using webrtcvad";
    homepage = "https://github.com/rhasspy/rhasspy-silence";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}

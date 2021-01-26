{ lib
, buildPythonPackage
, fetchPypi
, webrtcvad
}:

buildPythonPackage rec {
  pname = "rhasspy-silence";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-sl0y5c4ETdG6zz398XpyEiOTrWHGEW73SaQUXJ9vSc0=";
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

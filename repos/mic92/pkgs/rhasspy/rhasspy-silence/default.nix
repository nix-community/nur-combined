{ lib
, buildPythonPackage
, fetchPypi
, webrtcvad
}:

buildPythonPackage rec {
  pname = "rhasspy-silence";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "61ef6a3560bf58e90d55b35fef82d9b5970e483813cbb4106476ff8122880c6a";
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

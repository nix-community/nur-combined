{ stdenv, buildPythonPackage, fetchFromGitHub
, paho-mqtt, rhasspy-hermes }:

buildPythonPackage rec {
  pname = "rhasspy-wake-snowboy-hermes";
  version = "2020-06-03";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "ce3c729523c34d116ba83833982f9d800849fb20";
    sha256 = "1z8sqhn7nx4kcprngidx1d4vjvg65nyils6cj3air44mm7829ipb";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
  ];

  meta = with stdenv.lib; {
    description = "MQTT service for wake word detection with snowboy using Hermes protocol";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}

{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, rhasspy-hermes
, rhasspy-silence
, rhasspy-asr-deepspeech
}:

buildPythonPackage rec {
  pname = "rhasspy-asr-deepspeech-hermes";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "4edc40563b7f4b9788ce177fb754ee684144a4f1";
    sha256 = "sha256-ddL/3WhEVkHHdrSvMHDkMvhPEec+zQ5S+9QjrIgMcMo=";
  };

  dontConfigure = true;

  propagatedBuildInputs = [
    rhasspy-hermes
    rhasspy-silence
    rhasspy-asr-deepspeech
  ];

  postPatch = ''
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  # misses files
  doCheck = false;

  meta = with lib; {
    description = "MQTT service for Rhasspy using Mozilla's DeepSpeech with the Hermes protocol";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}

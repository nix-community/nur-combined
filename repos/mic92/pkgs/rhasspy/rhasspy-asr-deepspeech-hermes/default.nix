{ stdenv
, buildPythonPackage
, fetchFromGitHub
, rhasspy-hermes
, rhasspy-silence
, rhasspy-asr-deepspeech
}:

buildPythonPackage rec {
  pname = "rhasspy-asr-deepspeech-hermes";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "cff5d770d7e60faaa5854c874f31da963b118e58";
    sha256 = "sha256-Y/Ot4GT0iyR/t98U39UYgUcSzmH+UnaZRirG3koiG5E=";
  };

  dontConfigure = true;

  propagatedBuildInputs = [
    rhasspy-hermes
    rhasspy-silence
    rhasspy-asr-deepspeech
  ];

  postPatch = ''
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
    ls -la
  '';

  # misses files
  doCheck = false;

  meta = with stdenv.lib; {
    description = "MQTT service for Rhasspy using Mozilla's DeepSpeech with the Hermes protocol";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}

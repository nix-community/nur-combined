{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, rhasspy-hermes
, attrs
, rhasspy-asr-kaldi
, rhasspy-silence
}:

buildPythonPackage rec {
  pname = "rhasspy-asr-kaldi-hermes";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-u1SAEBJPG/1HqBNXg6PEBG270bgoIpubmKWA3d4vSCo=";
  };

  dontConfigure = true;

  propagatedBuildInputs = [
    rhasspy-hermes
    attrs
    rhasspy-asr-kaldi
    rhasspy-silence
  ];

  postPatch = ''
    sed -i 's/networkx==.*/networkx/' requirements.txt
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  # misses files
  doCheck = false;

  meta = with lib; {
    description = "Hotword detection for Rhasspy using Porcupine";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}

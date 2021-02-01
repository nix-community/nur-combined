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
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "de0b7e378b06e34cfe52630e40feba016c9e69c3";
    sha256 = "sha256-NzZGrOBru9cW6lH/d+dbzzI2AHzE70MCWB8W+FXiq3Q=";
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

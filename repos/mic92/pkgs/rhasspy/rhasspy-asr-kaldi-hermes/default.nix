{ stdenv, buildPythonPackage, fetchFromGitHub
, paho-mqtt, rhasspy-hermes, attrs
, rhasspy-asr-kaldi
, rhasspy-silence }:

buildPythonPackage rec {
  pname = "rhasspy-asr-kaldi-hermes";
  version = "2020-06-05";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "3eebce535180697641c5af55c9da01a3d8bd6862";
    sha256 = "0ki8nk5z556wrzvh8g5nkb62ilsfnw978v7wqbs3jw5fk7rlr64n";
  };

  dontConfigure = true;

  propagatedBuildInputs = [
    rhasspy-hermes
    attrs
    rhasspy-asr-kaldi
    rhasspy-silence
  ];

  # misses files
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Hotword detection for Rhasspy using Porcupine";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}

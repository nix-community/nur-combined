{ lib
, buildPythonPackage
, fetchFromGitHub
, numpy
, pyaudio
, soundfile
}:

buildPythonPackage rec {
  pname = "pvporcupine";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "Picovoice";
    repo = "porcupine";
    rev = "6ea24df46e1de8f1f43027bfa5b14977a2e4a541";
    sha256 = "sha256-1mNebtJPtYrJNMn9hRQCSj4gukloN3kaEDJvZdGaJHQ=";
  };

  postPatch = ''
    cd binding/python
    sed -i -e 's!"enum34",!!' setup.py
  '';

  propagatedBuildInputs = [
    numpy
    pyaudio
    soundfile
  ];
  # requires files not in pypi
  doCheck = false;

  meta = with lib; {
    description = "On-device wake word detection powered by deep learning.";
    homepage = "https://github.com/Picovoice/porcupine";
    license = licenses.asl20;
  };
}

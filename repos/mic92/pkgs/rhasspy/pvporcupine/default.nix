{ lib
, buildPythonPackage
, fetchFromGitHub
, numpy
, pyaudio
, soundfile
}:

buildPythonPackage rec {
  pname = "pvporcupine";
  version = "1.9.5";

  src = fetchFromGitHub {
    owner = "Picovoice";
    repo = "porcupine";
    rev = "a9e2c711da15092dde649e8db71d8a0f14cc6bd9";
    sha256 = "sha256-4mPdubF8Lr0AMvp1orFhjDIcFnKD6vOExBSaDfi4eUk=";
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

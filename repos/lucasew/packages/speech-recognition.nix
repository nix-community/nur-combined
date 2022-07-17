{ python3Packages
, lib
, fetchFromGitHub
, flac
, alsa-utils
, ... }:
python3Packages.buildPythonPackage rec {
  pname = "SpeechRecognition";
  version = "3.8.1";
  src = fetchFromGitHub {
    owner = "Uberi";
    repo = "speech_recognition";
    rev = "3.8.1";
    sha256 = "sha256-5OsffPcP95+WBI2qWO41fZDj+5mRmzUgIyv4QSd5BtM=";
  };
  dontBuildExt = true;
  buildInputs = with python3Packages; [
    pyaudio

    flac
    alsa-utils
  ];
  meta.broken = true;
}

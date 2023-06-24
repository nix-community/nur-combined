{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, pyaudio
, pkgs
, requests
}:

buildPythonPackage rec {
  pname = "SpeechRecognition";
  version = "3.10.0";
  src = fetchFromGitHub {
    owner = "Uberi";
    repo = "speech_recognition";
    rev = version;
    sha256 = "sha256-w+BXfzsEtikPLnHDCI48aXTVLRxfDg43IAOzuAShngY=";
  };
  propagatedBuildInputs = [
    pyaudio # PyAudio
    pkgs.flac
    requests
  ];
  doCheck = false; # error: No Default Input Device Available
  # TODO
  # flac-win32.exe
  # flac-linux-x86
  # flac-mac
  postInstall = ''
    echo replacing flac binary
    rm -v $out/${python.sitePackages}/speech_recognition/flac-*
    ln -v -s ${pkgs.flac}/bin/flac $out/${python.sitePackages}/speech_recognition/flac-linux-x86_64
  '';
  meta = with lib; {
    homepage = "https://github.com/Uberi/speech_recognition";
    description = "Library for performing speech recognition, with support for several engines and APIs, online and offline";
    license = licenses.bsdOriginal;
  };
}

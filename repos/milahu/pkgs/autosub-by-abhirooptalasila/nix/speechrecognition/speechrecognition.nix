{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, pyaudio
, pkgs
}:

buildPythonPackage rec {
  pname = "SpeechRecognition";
  version = "3.8.1.20220209";
  src = fetchFromGitHub {
    owner = "avryhof"; # active fork https://github.com/avryhof/speech_recognition
    # active fork? https://github.com/fossasia/speech_recognition
    repo = "speech_recognition";
    rev = "77a5b274d4e074448b58d6819065369c8c21ed05";
    sha256 = "KgBc0vnRxCpjRBrVnwm15WGG80s6sQ8Dz51IhnJLHoY=";
  };
  propagatedBuildInputs = [
    pyaudio # PyAudio
    pkgs.flac
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
    homepage = "https://github.com/avryhof/speech_recognition";
    description = "Library for performing speech recognition, with support for several engines and APIs, online and offline";
    license = licenses.bsdOriginal;
  };
}

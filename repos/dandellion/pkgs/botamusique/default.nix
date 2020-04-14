{ fetchFromGitHub, python3, python3Packages, ffmpeg, opusTools }:

let
  pythonEnv = python3.withPackages (pythonPackages: with pythonPackages; [
    opuslib
    protobuf
    flask
    youtube-dl
    magic
    pillow
    mutagen
    requests
    packaging
  ]);
in

python3Packages.buildPythonApplication rec {
  pname = "botamusique";
  version = "6.1.1";

  src = fetchFromGitHub {
    owner = "azlux";
    repo = "botamusique";
    fetchSubmodules = true;
    rev = "${version}";
    sha256 = "0fmdxi8fsi3qqx9f8sjlnml656l46dx93l7amhhp6zvpnmr6fl1n";
  };

  buildInputs = [ ffmpeg opusTools ];

  meta = {
    broken = true;
  };


}
